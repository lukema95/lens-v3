// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IUsernameRules} from './IUsernameRules.sol';

contract RulesCombinator {
    enum CombinationMode {
        AND,
        OR
    }

    address[] internal _rules;
    CombinationMode internal _combinationMode;

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
    // TODO: Add a possibility to reinitialize an individual rule (change it)

    function initialize(bytes calldata data) external override {
        (address[] memory rules, CombinationMode combinationMode, bytes[] memory rulesInitDatas) = abi.decode(
            data,
            (address[], CombinationMode, bytes[])
        );

        _setRules(rules, combinationMode);

        for (uint256 i = 0; i < rules.length; i++) {
            IUsernameRules(rules[i]).initialize(rulesInitDatas[i]);
        }
    }

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
