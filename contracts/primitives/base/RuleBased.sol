// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IRule} from "./../rules/IRule.sol";
import {RuleConfiguration} from "./../../types/Types.sol";

contract RuleBased {
    struct RuleState {
        uint8 index;
        bool isRequired;
        bool isSet;
    }

    struct RulesStorage {
        address[] requiredRules;
        address[] anyOfRules;
        mapping(address => RuleState) ruleStates;
    }

    struct RuleBasedStorage {
        mapping(bytes32 => RulesStorage) rulesStorage;
    }

    // keccak256('lens.rule.based.storage')
    bytes32 constant RULE_BASED_STORAGE_SLOT = 0x78c2efc16b0e28b79e7018ec8a12d1eec1218d52bcd7993a02f6763876b0ceb6;

    function $ruleBasedStorage() private pure returns (RuleBasedStorage storage _storage) {
        assembly {
            _storage.slot := RULE_BASED_STORAGE_SLOT
        }
    }

    bytes32 private immutable DEFAULT_RULES_STORAGE_KEY;

    constructor(bytes32 defaultRulesStorageKey) {
        DEFAULT_RULES_STORAGE_KEY = defaultRulesStorageKey;
    }

    // Internal

    function _addRule(RuleConfiguration memory rule) internal virtual {
        _addRule(DEFAULT_RULES_STORAGE_KEY, rule);
    }

    function _updateRule(RuleConfiguration memory rule) internal virtual {
        _updateRule(DEFAULT_RULES_STORAGE_KEY, rule);
    }

    function _removeRule(address rule) internal virtual {
        _removeRule(DEFAULT_RULES_STORAGE_KEY, rule);
    }

    function _addRule(bytes32 ruleStorageKey, RuleConfiguration memory rule) internal virtual {
        require(!_ruleAlreadySet(ruleStorageKey, rule.ruleAddress), "RuleAlreadySet");
        _addRuleToStorage(ruleStorageKey, rule.ruleAddress, rule.isRequired);
        IRule(rule.ruleAddress).configure(rule.configData);
    }

    function _updateRule(bytes32 ruleStorageKey, RuleConfiguration memory rule) internal virtual {
        require(_ruleAlreadySet(ruleStorageKey, rule.ruleAddress), "RuleNotSet");
        if ($ruleBasedStorage().rulesStorage[ruleStorageKey].ruleStates[rule.ruleAddress].isRequired != rule.isRequired)
        {
            _removeRuleFromStorage(ruleStorageKey, rule.ruleAddress);
            _addRuleToStorage(ruleStorageKey, rule.ruleAddress, rule.isRequired);
        }
        IRule(rule.ruleAddress).configure(rule.configData);
    }

    function _removeRule(bytes32 ruleStorageKey, address rule) internal virtual {
        require(_ruleAlreadySet(ruleStorageKey, rule), "RuleNotSet");
        _removeRuleFromStorage(ruleStorageKey, rule);
    }

    // Private

    function _addRuleToStorage(bytes32 ruleStorageKey, address ruleAddress, bool requiredRule) private {
        address[] storage rules = _getRulesArray(ruleStorageKey, requiredRule);
        uint8 index = uint8(rules.length); // TODO: Add a check if needed
        rules.push(ruleAddress);
        $ruleBasedStorage().rulesStorage[ruleStorageKey].ruleStates[ruleAddress] =
            RuleState({index: index, isRequired: requiredRule, isSet: true});
    }

    function _removeRuleFromStorage(bytes32 ruleStorageKey, address ruleAddress) private {
        uint8 index = $ruleBasedStorage().rulesStorage[ruleStorageKey].ruleStates[ruleAddress].index;
        address[] storage rules = _getRulesArray(
            ruleStorageKey, $ruleBasedStorage().rulesStorage[ruleStorageKey].ruleStates[ruleAddress].isRequired
        );
        if (rules.length > 1) {
            // Copy the last element in the array into the index of the rule to delete
            rules[index] = rules[rules.length - 1];
            // Set the proper index for the swapped rule
            $ruleBasedStorage().rulesStorage[ruleStorageKey].ruleStates[rules[index]].index = index;
        }
        rules.pop();
        delete $ruleBasedStorage().rulesStorage[ruleStorageKey].ruleStates[ruleAddress];
    }

    function _ruleAlreadySet(bytes32 ruleStorageKey, address rule) private view returns (bool) {
        return $ruleBasedStorage().rulesStorage[ruleStorageKey].ruleStates[rule].isSet;
    }

    function _getRulesArray(bytes32 ruleStorageKey, bool requiredRules) private view returns (address[] storage) {
        return requiredRules
            ? $ruleBasedStorage().rulesStorage[ruleStorageKey].requiredRules
            : $ruleBasedStorage().rulesStorage[ruleStorageKey].anyOfRules;
    }
}
