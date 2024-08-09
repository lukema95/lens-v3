// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {RulesCombinator} from 'src/primitives/rules/RulesCombinator.sol';
import {IPostRules} from './IPostRules.sol';
import {IFeedRules} from './IFeedRules.sol';
import {PostParams} from './IFeed.sol';

contract FeedRulesCombinator is RulesCombinator, IFeedRules {
    function processCreatePost(
        address originalMsgSender,
        uint256 postId,
        PostParams calldata postParams,
        bytes calldata data
    ) external override {
        bytes[] memory ruleSpecificDatas = abi.decode(data, (bytes[]));
        bytes[] memory datas = new bytes[](_rules.length);
        for (uint256 i = 0; i < _rules.length; i++) {
            datas[i] = abi.encodeWithSelector(
                IFeedRules.processCreatePost.selector,
                originalMsgSender,
                postId,
                postParams,
                ruleSpecificDatas[i]
            );
        }
        _processRules(datas);
    }

    function processEditPost(
        address originalMsgSender,
        uint256 postId,
        PostParams calldata newPostParams,
        bytes calldata data
    ) external {
        bytes[] memory ruleSpecificDatas = abi.decode(data, (bytes[]));
        bytes[] memory datas = new bytes[](_rules.length);
        for (uint256 i = 0; i < _rules.length; i++) {
            datas[i] = abi.encodeWithSelector(
                IFeedRules.processEditPost.selector,
                originalMsgSender,
                postId,
                newPostParams,
                ruleSpecificDatas[i]
            );
        }
        _processRules(datas);
    }

    function processDeletePost(address originalMsgSender, uint256 postId, bytes calldata data) external {
        bytes[] memory ruleSpecificDatas = abi.decode(data, (bytes[]));
        bytes[] memory datas = new bytes[](_rules.length);
        for (uint256 i = 0; i < _rules.length; i++) {
            datas[i] = abi.encodeWithSelector(
                IFeedRules.processDeletePost.selector,
                originalMsgSender,
                postId,
                ruleSpecificDatas[i]
            );
        }
        _processRules(datas);
    }

    function processPostRulesChange(
        address originalMsgSender,
        uint256 postId,
        IPostRules newPostRules,
        bytes calldata data
    ) external {
        bytes[] memory ruleSpecificDatas = abi.decode(data, (bytes[]));
        bytes[] memory datas = new bytes[](_rules.length);
        for (uint256 i = 0; i < _rules.length; i++) {
            datas[i] = abi.encodeWithSelector(
                IFeedRules.processPostRulesChange.selector,
                originalMsgSender,
                postId,
                newPostRules,
                ruleSpecificDatas[i]
            );
        }
        _processRules(datas);
    }
}
