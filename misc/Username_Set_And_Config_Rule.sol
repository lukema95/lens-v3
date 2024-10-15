// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {UsernameCore as Core} from "./UsernameCore.sol";
import {IUsernameRules} from "./IUsernameRules.sol";
import {IUsername} from "./IUsername.sol";
import {IAccessControl} from "./../access-control/IAccessControl.sol";

contract Username is IUsername {
    constructor(string memory namespace, IAccessControl accessControl) {
        Core.$storage().namespace = namespace;
        Core.$storage().accessControl = address(accessControl);
    }

    uint256 constant SET_RULES_PID = uint256(keccak256("SET_RULES"));

    // Owner functions

    function setUsernameRules(address usernameRules, bytes calldata configurationData) external {
        require(
            IAccessControl(Core.$storage().accessControl).hasAccess({
                account: msg.sender,
                contractAddress: address(this),
                permissionId: SET_RULES_PID
            })
        ); // msg.sender must have permissions to set rules
        Core.$storage().usernameRules = usernameRules;
        if (address(usernameRules) != address(0)) {
            IUsernameRules(usernameRules).configure(msg.sender, configurationData);
        }
        emit Lens_Username_RulesSet(usernameRules, configurationData);
    }

    // Public functions

    function registerUsername(address account, string memory username, bytes calldata data) external {
        require(msg.sender == account); // msg.sender must be the account
        IUsernameRules(Core.$storage().usernameRules).processRegistering(msg.sender, account, username, data);
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
