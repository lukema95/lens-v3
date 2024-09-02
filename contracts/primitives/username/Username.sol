// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {UsernameCore as Core} from "./UsernameCore.sol";
import {IUsernameRule} from "./IUsernameRule.sol";
import {IUsername} from "./IUsername.sol";
import {IAccessControl} from "./../access-control/IAccessControl.sol";

contract Username is IUsername {
    // Resource IDs involved in the contract
    uint256 constant SET_RULES_RID = uint256(keccak256("SET_RULES"));
    uint256 constant CHANGE_ACCESS_CONTROL_RID = uint256(keccak256("CHANGE_ACCESS_CONTROL"));

    // Storage fields and structs
    struct LengthRestriction {
        uint8 min;
        uint8 max;
    }

    constructor(string memory namespace, IAccessControl accessControl) {
        Core.$storage().namespace = namespace;
        accessControl.hasAccess(address(0), address(0), 0); // We expect this to not panic.
        Core.$storage().accessControl = address(accessControl);
    }

    // Access Controlled functions

    // TODO: This is a 1-step operation, while some of our AC owner transfers are a 2-step, or even 3-step operations.
    function setAccessControl(IAccessControl accessControl) external {
        require(
            IAccessControl(Core.$storage().accessControl).hasAccess({
                account: msg.sender,
                resourceLocation: address(this),
                resourceId: CHANGE_ACCESS_CONTROL_RID
            })
        ); // msg.sender must have permissions to change access control
        accessControl.hasAccess(address(0), address(0), 0); // We expect this to not panic.
        Core.$storage().accessControl = address(accessControl);
    }

    function setUsernameRules(IUsernameRule usernameRules) external {
        require(
            IAccessControl(Core.$storage().accessControl).hasAccess({
                account: msg.sender,
                resourceLocation: address(this),
                resourceId: SET_RULES_RID
            })
        ); // msg.sender must have permissions to set rules
        Core.$storage().usernameRules = address(usernameRules);
        emit Lens_Username_RulesSet(address(usernameRules));
    }

    // Permissionless functions

    function registerUsername(address account, string memory username, bytes calldata data) external {
        require(msg.sender == account); // msg.sender must be the account
        IUsernameRule(Core.$storage().usernameRules).processRegistering(msg.sender, account, username, data);
        _validateUsernameLength(username);
        Core._registerUsername(account, username);
        emit Lens_Username_Registered(username, account, data);
    }

    // TODO: Decide if it worth to have a "before/after" hook for the rules, or if we are covered just with the "before"
    // Think about CEI pattern and if we are OK with the "before", because it looks more like CIE than CEI.
    // function registerUsername(address account, string memory username, bytes calldata data) external {
    //     require(msg.sender == account); // msg.sender must be the account
    //     IUsernameRule(Core.$storage().usernameRules).beforeRegistering(msg.sender, account, username, data);
    //     Core._registerUsername(account, username);
    //     IUsernameRule(Core.$storage().usernameRules).afterRegistering(msg.sender, account, username, data);
    //     emit Lens_Username_Registered(username, account, data);
    // }

    function unregisterUsername(string memory username, bytes calldata data) external {
        address account = Core.$storage().usernameToAccount[username];
        require(msg.sender == account); // msg.sender must be the account
        IUsernameRule(Core.$storage().usernameRules).processUnregistering(msg.sender, account, username, data);
        Core._unregisterUsername(username);
        emit Lens_Username_Unregistered(username, account, data);
    }

    // Internal

    function _validateUsernameLength(string memory username) internal pure {
        // TODO: Add the RIDs for skipping length restrictions.
        LengthRestriction memory lengthRestriction = $lengthRestriction();
        uint256 usernameLength = bytes(username).length;
        if (lengthRestriction.min != 0) {
            require(usernameLength >= lengthRestriction.min, "Username: too short");
        }
        if (lengthRestriction.max != 0) {
            // TODO: If no restriction, should be max(uint8), not unlimited! - API will be like that
            require(usernameLength <= lengthRestriction.max, "Username: too long");
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
