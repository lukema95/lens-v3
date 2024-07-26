// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {UsernameCore as Core} from './UsernameCore.sol';
import {IUsernameRules} from './IUsernameRules.sol';
import {IUsername} from './IUsername.sol';

contract Username_WithAlotOfShit is IUsername {
    constructor(string memory namespace, address owner) {
        Core.$storage().namespace = namespace;
        Core.$storage().owner = owner;
    }

    /*
        1. Solve configure (add/remove/update) for the RuleCombinator (and Rule interface)
        2. Modify the Rules interface so the rules can be updated
        3. Solve these FIRST and SECOND chapters below.
        4. Emit all events from the primitive (cause all rule actions will go from primitive)
        5. Check if we solved the SomeNotes.txt

    -------------
    FIRST CHAPTER
    -------------

    We want to set a UsernamePayToRegisterRule as a single rule on this primitive:

        1. We call setUsernameRules(payToRegisterAddress, abi.encode(token, amount))
          - this makes an event fire: Lens_Username_RulesSet(payToRegisterAddress, abi.encode(token, amount))

    What if we set the RuleCombinator with a single rule instead?

        1. We deploy a RuleCombinator
        2. We call setUsernameRules(ruleCombinator, abi.encode([payToRegisterAddress], AND_OR, [abi.encode(token, amount)]))
          - This makes an event fire: Lens_Username_RulesSet(ruleCombinator, abi.encode([payToRegisterAddress], AND_OR, [abi.encode(token, amount)]))

    My question here (and probably Josh's one too) is:
        How the fuck do we differentiate between those two cases on the API/Indexer/backend level?    

    --------------
    SECOND CHAPTER
    --------------

    We want to change an amount to Pay in UsernamePayToRegisterRule. How do we do that?

    If it's a single rule on this primitive, we do:
        1.


    If it's a single rule inside a RuleCombinator on this primitive, we do:
        2.    

    */

    // Owner functions

    // This is the first time you set the rules and also initialize them
    function setUsernameRulesAddress(address usernameRules) external {
        require(msg.sender == Core.$storage().owner); // msg.sender must be owner
        Core.$storage().usernameRules = usernameRules;
        emit Lens_Username_RulesAddressSet(usernameRules);
    }

    function initializeUsernameRules(bytes calldata initializationData) external {
        require(msg.sender == Core.$storage().owner); // msg.sender must be owner
        IUsernameRules usernameRules = IUsernameRules(Core.$storage().usernameRules);
        usernameRules.initialize(initializationData);
        emit Lens_Username_RulesInitialized(usernameRules, initializationData);
    }

    function updateUsernameRulesParams(bytes calldata updateData) external {
        require(msg.sender == Core.$storage().owner); // msg.sender must be owner
        IUsernameRules usernameRules = IUsernameRules(Core.$storage().usernameRules);
        usernameRules.update(updateData);
        emit Lens_Username_RulesUpdated(Core.$storage().usernameRules, updateData);
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
