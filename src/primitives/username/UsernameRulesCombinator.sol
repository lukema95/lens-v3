// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {RulesCombinator} from 'src/primitives/rules/RulesCombinator.sol';
import {IUsernameRules} from './IUsernameRules.sol';

contract UsernameRulesCombinator is RulesCombinator, IUsernameRules {
    function setRolePermissions(
        uint256 role,
        bool canSetRolePermissions,
        bool canConfigureRulesAndCombinationMode
    ) external {
        require(_rolePermissions[_accessControl.getRole(msg.sender)].canSetRolePermissions); // Must have canSetRolePermissions
        _rolePermissions[role] = Permissions(canSetRolePermissions, canConfigureRulesAndCombinationMode);
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
