// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IRules} from './IRules.sol';
import {IUsernameRules} from './IUsernameRules.sol';

contract RulesCombinator is IRules {
    enum CombinationMode {
        AND,
        OR
    }

    address[] internal _rules;
    CombinationMode internal _combinationMode;

    enum Mode {
        ADD,
        REMOVE,
        UPDATE
    }

    struct RuleConfiguration {
        address rule;
        bytes ruleData;
    }

    // configure() function of the RuleCombinator can do magic:
    // - You pass a MODE: Add, Remove, Update
    // - You pass a list of rules to remove, or to update or to add
    function configure(bytes calldata data) external virtual {
        (Mode mode, bytes memory rulesData) = abi.decode(data, (Mode, bytes));

        if (mode == Mode.ADD) {
            _addRules(rulesData);
        } else if (mode == Mode.REMOVE) {
            _removeRules(rulesData);
        } else if (mode == Mode.UPDATE) {
            _updateRules(rulesData);
        } else {
            revert('UsernameRulesCombinator: Invalid mode');
        }
    }

    function setCombinationMode(CombinationMode combinationMode) external {
        _combinationMode = combinationMode;
    }

    function getCombinationMode() external view returns (CombinationMode) {
        return _combinationMode;
    }

    function _addRules(bytes memory rulesData) internal {
        RuleConfiguration[] memory rules = abi.decode(rulesData, (RuleConfiguration[]));
        for (uint256 i = 0; i < rules.length; i++) {
            _addRule(rules[i]);
        }
    }

    function _addRule(RuleConfiguration memory rule) internal {
        // Check if the rule address already exists in the array
        for (uint256 i = 0; i < _rules.length; i++) {
            if (_rules[i] == rule.rule) {
                revert('UsernameRulesCombinator: Rule already exists');
            }
        }
        _rules.push(rule.rule);
        IUsernameRules(rule.rule).configure(rule.ruleData);
    }

    function _removeRules(bytes memory rulesData) internal {
        address[] memory rulesToRemove = abi.decode(rulesData, (address[]));
        for (uint256 i = 0; i < rulesToRemove.length; i++) {
            _removeRule(rulesToRemove[i]);
        }
    }

    function _removeRule(address ruleToRemove) internal {
        // Find the rule index and delete it from the _rules array
        for (uint256 i = 0; i < _rules.length; i++) {
            if (_rules[i] == ruleToRemove) {
                delete _rules[i];
                return;
            }
        }
        revert('UsernameRulesCombinator: Rule not found');
    }

    function _updateRules(bytes memory rulesData) internal {
        RuleConfiguration[] memory rules = abi.decode(rulesData, (RuleConfiguration[]));
        for (uint256 i = 0; i < rules.length; i++) {
            _updateRule(rules[i]);
        }
    }

    function _updateRule(RuleConfiguration memory rule) internal {
        // Find the rule index and update it
        for (uint256 i = 0; i < _rules.length; i++) {
            if (_rules[i] == rule.rule) {
                IUsernameRules(rule.rule).configure(rule.ruleData);
                return;
            }
        }
        revert('UsernameRulesCombinator: Rule not found');
    }

    function _setRules(address[] memory rules, CombinationMode combinationMode) internal {
        rules = rules;
        _combinationMode = combinationMode;
    }

    function getRules() external view returns (address[] memory, CombinationMode) {
        return (_rules, _combinationMode);
    }

    function _processRules(bytes[] memory datas) internal {
        if (_combinationMode == CombinationMode.AND) {
            _processRules_AND(datas);
        } else {
            _processRules_OR(datas);
        }
    }

    function _processRules_AND(bytes[] memory datas) internal {
        for (uint256 i = 0; i < _rules.length; i++) {
            (bool success, ) = _rules[i].delegatecall(datas[i]);
            if (!success) {
                revert('RulesCombinator: Innter OR Rule failed, so outer AND Rule will fail now');
            }
        }
        return; // If it didn't revert above - all passed
    }

    function _processRules_OR(bytes[] memory datas) internal {
        for (uint256 i = 0; i < _rules.length; i++) {
            (bool success, ) = _rules[i].delegatecall(datas[i]);
            if (success) {
                return; // If any of the rules passed, we can return
            }
        }
        revert('RulesCombinator: All OR Rules failed');
    }
}

contract UsernameRulesCombinator is RulesCombinator, IUsernameRules {
    function processRegistering(
        address originalMsgSender,
        address account,
        string memory username,
        bytes memory data
    ) external override {
        bytes[] memory ruleSpecificDatas = abi.decode(data, (bytes[]));
        bytes[] memory datas = new bytes[](_rules.length);
        for (uint256 i = 0; i < _rules.length; i++) {
            datas[i] = abi.encodeWithSelector(
                IUsernameRules.processRegistering.selector,
                originalMsgSender,
                account,
                username,
                ruleSpecificDatas[i]
            );
        }
        _processRules(datas);
    }

    function processUnregistering(
        address originalMsgSender,
        address account,
        string memory username,
        bytes memory data
    ) external override {
        bytes[] memory ruleSpecificDatas = abi.decode(data, (bytes[]));
        bytes[] memory datas = new bytes[](_rules.length);
        for (uint256 i = 0; i < _rules.length; i++) {
            datas[i] = abi.encodeWithSelector(
                IUsernameRules.processUnregistering.selector,
                originalMsgSender,
                account,
                username,
                ruleSpecificDatas[i]
            );
        }
        _processRules(datas);
    }
}
