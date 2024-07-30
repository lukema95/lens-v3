// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {UsernameCore as Core} from './UsernameCore.sol';
import {IUsernameRules} from './IUsernameRules.sol';
import {IUsername} from './IUsername.sol';
import {IAccessControl} from './../access-control/IAccessControl.sol';

contract Username is IUsername {
    // Resource IDs involved in the contract
    uint256 constant SET_RULES_RID = uint256(keccak256('SET_RULES'));

    // Storage fields and structs
    struct LengthRestriction {
        uint128 min;
        uint128 max;
    }

    constructor(string memory namespace, IAccessControl accessControl) {
        Core.$storage().namespace = namespace;
        Core.$storage().accessControl = address(accessControl);
    }

    // Access Controlled functions

    function setUsernameRules(address usernameRules) external {
        require(
            IAccessControl(Core.$storage().accessControl).hasAccess({
                account: msg.sender,
                resourceLocation: address(this),
                resourceId: SET_RULES_RID
            })
        ); // msg.sender must have permissions to set rules
        Core.$storage().usernameRules = usernameRules;
        emit Lens_Username_RulesSet(usernameRules);
    }

    // Permissionless functions

    function registerUsername(address account, string memory username, bytes calldata data) external {
        require(msg.sender == account); // msg.sender must be the account
        IUsernameRules(Core.$storage().usernameRules).processRegistering(msg.sender, account, username, data);
        _validateUsernameLength(username);
        Core._registerUsername(account, username);
        emit Lens_Username_Registered(username, account, data);
    }

    // TODO: Decide if it worth to have a "before/after" hook for the rules, or if we are covered just with the "before"
    // function registerUsername(address account, string memory username, bytes calldata data) external {
    //     require(msg.sender == account); // msg.sender must be the account
    //     IUsernameRules(Core.$storage().usernameRules).beforeRegistering(msg.sender, account, username, data);
    //     Core._registerUsername(account, username);
    //     IUsernameRules(Core.$storage().usernameRules).afterRegistering(msg.sender, account, username, data);
    //     emit Lens_Username_Registered(username, account, data);
    // }

    function unregisterUsername(string memory username, bytes calldata data) external {
        address account = Core.$storage().usernameToAccount[username];
        require(msg.sender == account); // msg.sender must be the account
        IUsernameRules(Core.$storage().usernameRules).processUnregistering(msg.sender, account, username, data);
        Core._unregisterUsername(username);
        emit Lens_Username_Unregistered(username, account, data);
    }

    // Internal

    function _validateUsernameLength(string memory username) internal pure {
        // TODO: Add the RIDs for skipping length restrictions.
        LengthRestriction memory lengthRestriction = $lengthRestriction();
        uint256 usernameLength = bytes(username).length;
        if (lengthRestriction.min != 0) {
            require(usernameLength >= lengthRestriction.min, 'Username: too short');
        }
        if (lengthRestriction.max != 0) {
            require(usernameLength <= lengthRestriction.max, 'Username: too long');
        }
    }

    // Storage utility & helper functions

    // keccak256('lens.username.storage.length.restriction')
    bytes32 constant LENGTH_RESTRICTION_STORAGE_SLOT =
        0x2d828a00137871809f1a4bee7ddd78f42d45a25fe20299ceaf25638343e83134;

    function $lengthRestriction() internal pure returns (LengthRestriction storage _lengthRestriction) {
        assembly {
            _lengthRestriction.slot := LENGTH_RESTRICTION_STORAGE_SLOT
        }
    }

    // Getters

    function usernameOf(address user) external view returns (string memory) {
        return Core.$storage().accountToUsername[user];
    }

    function accountOf(string memory name) external view returns (address) {
        return Core.$storage().usernameToAccount[name];
    }

    function getNamespace() external view returns (string memory) {
        return Core.$storage().namespace;
    }

    function getUsernameRules() external view returns (address) {
        return Core.$storage().usernameRules;
    }

    function getAccessControl() external view returns (address) {
        return Core.$storage().accessControl;
    }
}
