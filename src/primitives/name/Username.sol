// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {UsernameCore as Core} from './UsernameCore.sol';
import {IUsernameRules} from './IUsernameRules.sol';
import {IUsername} from './IUsername.sol';

contract Username is IUsername {
    constructor(string memory namespace, address owner) {
        Core.$storage().namespace = namespace;
        Core.$storage().owner = owner;
    }

    // Owner functions

    function setUsernameRules(address usernameRules, bytes calldata initializationData) external {
        require(msg.sender == Core.$storage().owner); // msg.sender must be owner
        Core.$storage().usernameRules = usernameRules;
        if (address(usernameRules) != address(0)) {
            IUsernameRules(usernameRules).initialize(initializationData);
        }
    }

    // Public functions

    function registerUsername(address account, string memory username, bytes calldata data) external {
        require(msg.sender == account); // msg.sender must be the account
        IUsernameRules(Core.$storage().usernameRules).processRegistering(msg.sender, account, username, data);
        Core._registerUsername(account, username);
        emit Lens_Username_Registered(username, account, data);
    }

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

    function getOwner() external view returns (address) {
        return Core.$storage().owner;
    }
}
