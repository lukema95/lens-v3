// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {RuleCombinator} from "./../rules/RuleCombinator.sol";
import {IGraphRule} from "./IGraphRule.sol";
import {IFollowRule} from "./../graph/IFollowRule.sol";

contract GraphRuleCombinator is RuleCombinator, IGraphRule {
    function processFollow(
        address originalMsgSender,
        address followerAcount,
        address accountToFollow,
        uint256 followId,
        bytes calldata data
    ) external {
        bytes[] memory ruleSpecificDatas = abi.decode(data, (bytes[]));
        bytes[] memory datas = new bytes[](_rules.length);
        for (uint256 i = 0; i < _rules.length; i++) {
            datas[i] = abi.encodeWithSelector(
                IGraphRule.processFollow.selector,
                originalMsgSender,
                followerAcount,
                accountToFollow,
                followId,
                ruleSpecificDatas[i]
            );
        }
        _processRules(datas);
    }

    function processUnfollow(
        address originalMsgSender,
        address followerAccount,
        address accountToUnfollow,
        uint256 followId,
        bytes calldata data
    ) external {
        bytes[] memory ruleSpecificDatas = abi.decode(data, (bytes[]));
        bytes[] memory datas = new bytes[](_rules.length);
        for (uint256 i = 0; i < _rules.length; i++) {
            datas[i] = abi.encodeWithSelector(
                IGraphRule.processUnfollow.selector,
                originalMsgSender,
                followerAccount,
                accountToUnfollow,
                followId,
                ruleSpecificDatas[i]
            );
        }
        _processRules(datas);
    }

    function processBlock(address account, bytes calldata data) external {
        bytes[] memory ruleSpecificDatas = abi.decode(data, (bytes[]));
        bytes[] memory datas = new bytes[](_rules.length);
        for (uint256 i = 0; i < _rules.length; i++) {
            datas[i] = abi.encodeWithSelector(IGraphRule.processBlock.selector, account, ruleSpecificDatas[i]);
        }
        _processRules(datas);
    }

    function processUnblock(address account, bytes calldata data) external {
        bytes[] memory ruleSpecificDatas = abi.decode(data, (bytes[]));
        bytes[] memory datas = new bytes[](_rules.length);
        for (uint256 i = 0; i < _rules.length; i++) {
            datas[i] = abi.encodeWithSelector(IGraphRule.processUnblock.selector, account, ruleSpecificDatas[i]);
        }
        _processRules(datas);
    }

    function processFollowRulesChange(address account, IFollowRule followRules, bytes calldata data) external {
        bytes[] memory ruleSpecificDatas = abi.decode(data, (bytes[]));
        bytes[] memory datas = new bytes[](_rules.length);
        for (uint256 i = 0; i < _rules.length; i++) {
            datas[i] = abi.encodeWithSelector(
                IGraphRule.processFollowRulesChange.selector, account, followRules, ruleSpecificDatas[i]
            );
        }
        _processRules(datas);
    }
}
