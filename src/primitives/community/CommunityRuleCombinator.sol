// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {RulesCombinator} from 'src/primitives/rules/RulesCombinator.sol';
import {ICommunityRules} from './ICommunityRules.sol';

contract CommunityRuleCombinator is RulesCombinator, ICommunityRules {
    function processJoining(address originalMsgSender, address account, bytes calldata data) external {
        bytes[] memory ruleSpecificDatas = abi.decode(data, (bytes[]));
        bytes[] memory datas = new bytes[](_rules.length);
        for (uint256 i = 0; i < _rules.length; i++) {
            datas[i] = abi.encodeWithSelector(
                ICommunityRules.processJoining.selector,
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
                ICommunityRules.processRemoval.selector,
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
                ICommunityRules.processLeaving.selector,
                originalMsgSender,
                account,
                ruleSpecificDatas[i]
            );
        }
        _processRules(datas);
    }
}
