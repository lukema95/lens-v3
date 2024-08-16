// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {RuleCombinator} from 'src/primitives/rules/RuleCombinator.sol';
import {ICommunityRule} from './ICommunityRule.sol';

contract CommunityRuleCombinator is RuleCombinator, ICommunityRule {
    function processJoining(address originalMsgSender, address account, bytes calldata data) external {
        bytes[] memory ruleSpecificDatas = abi.decode(data, (bytes[]));
        bytes[] memory datas = new bytes[](_rules.length);
        for (uint256 i = 0; i < _rules.length; i++) {
            datas[i] = abi.encodeWithSelector(
                ICommunityRule.processJoining.selector,
                originalMsgSender,
                account,
                ruleSpecificDatas[i]
            );
        }
        _processRules(datas);
    }

    function processRemoval(address originalMsgSender, address account, bytes calldata data) external {
        bytes[] memory ruleSpecificDatas = abi.decode(data, (bytes[]));
        bytes[] memory datas = new bytes[](_rules.length);
        for (uint256 i = 0; i < _rules.length; i++) {
            datas[i] = abi.encodeWithSelector(
                ICommunityRule.processRemoval.selector,
                originalMsgSender,
                account,
                ruleSpecificDatas[i]
            );
        }
        _processRules(datas);
    }

    function processLeaving(address originalMsgSender, address account, bytes calldata data) external {
        bytes[] memory ruleSpecificDatas = abi.decode(data, (bytes[]));
        bytes[] memory datas = new bytes[](_rules.length);
        for (uint256 i = 0; i < _rules.length; i++) {
            datas[i] = abi.encodeWithSelector(
                ICommunityRule.processLeaving.selector,
                originalMsgSender,
                account,
                ruleSpecificDatas[i]
            );
        }
        _processRules(datas);
    }
}
