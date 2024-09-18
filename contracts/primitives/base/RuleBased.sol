// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AccessControlled} from "./AccessControlled.sol";
import {IAccessControl} from "./../access-control/IAccessControl.sol";
import {IRule} from "./../rules/IRule.sol";

contract RuleBased is AccessControlled {
    uint256 constant SET_RULES_RID = uint256(keccak256("SET_RULES"));

    struct RuleState {
        uint8 index;
        bool isRequired;
        bool isSet;
    }

    struct RuleBasedStorage {
        address[] requiredRules;
        address[] anyOfRules;
        mapping(address => RuleState) ruleStates;
    }

    struct RuleConfiguration {
        address contractAddress;
        bytes data;
    }

    // keccak256('lens.rule.based.storage')
    bytes32 constant RULE_BASED_STORAGE_SLOT = 0x78c2efc16b0e28b79e7018ec8a12d1eec1218d52bcd7993a02f6763876b0ceb6;

    function $storage() private pure returns (RuleBasedStorage storage _storage) {
        assembly {
            _storage.slot := RULE_BASED_STORAGE_SLOT
        }
    }

    constructor(IAccessControl accessControl) AccessControlled(accessControl) {}

    function _addRule(RuleConfiguration memory rule, bool requiredRule) internal virtual {
        require(!_ruleAlreadySet(rule.contractAddress), "RuleAlreadySet");
        _addRuleToStorage(rule.contractAddress, requiredRule);
        IRule(rule.contractAddress).configure(rule.data);
        // emit Lens_RuleAdded(rule.contractAddress, rule.data, requiredRule);
    }

    function _updateRule(RuleConfiguration memory rule, bool requiredRule) internal virtual {
        require(_ruleAlreadySet(rule.contractAddress), "RuleNotSet");
        if ($storage().ruleStates[rule.contractAddress].isRequired != requiredRule) {
            _removeRuleFromStorage(rule.contractAddress);
            _addRuleToStorage(rule.contractAddress, requiredRule);
        }
        IRule(rule.contractAddress).configure(rule.data);
        // emit Lens_RuleUpdated(rule.contractAddress, rule.data);
    }

    function _removeRule(address rule) internal virtual {
        require(_ruleAlreadySet(rule), "RuleNotSet");
        _removeRuleFromStorage(rule);
    }

    function _ruleAlreadySet(address rule) internal view returns (bool) {
        return $storage().ruleStates[rule].isSet;
    }

    function _addRuleToStorage(address rule, bool requiredRule) private {
        address[] storage rules = _getRulesArray(requiredRule);
        uint8 index = rules.length;
        rules.push(rule);
        $storage().ruleStates[rule] = RuleState({index: index, isRequired: requiredRule, isSet: true});
    }

    function _removeRuleFromStorage(address rule) private {
        uint8 index = $storage().ruleStates[rule].index;
        address[] storage rules = _getRulesArray($storage().ruleStates[rule].isRequired);
        if (rules.length > 1) {
            // Copy the last element in the array into the index of the rule to delete
            rules[index] = rules[rules.length - 1];
            // Set the proper index for the swapped rule
            $storage().ruleStates[rules[index]].index = index;
        }
        rules.pop();
        delete $storage().ruleStates[rule];
    }

    function _getRulesArray(bool requiredRules) internal view returns (address[] storage) {
        return requiredRules ? $storage().requiredRules : $storage().anyOfRules;
    }
}
