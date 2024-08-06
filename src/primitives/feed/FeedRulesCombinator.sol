// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {RulesCombinator} from 'src/primitives/rules/RulesCombinator.sol';
import {IPostRules} from './IPostRules.sol';
import {IFeedRules} from './IFeedRules.sol';
import {PostParams} from './IFeed.sol';

contract FeedRulesCombinator is RulesCombinator, IFeedRules {
    function processCreatePost(
        address originalMsgSender,
        address account,
        PostParams calldata postParams,
        bytes calldata data
    ) external {
        bytes[] memory ruleSpecificDatas = abi.decode(data, (bytes[]));
        bytes[] memory datas = new bytes[](_rules.length);
        for (uint256 i = 0; i < _rules.length; i++) {
            datas[i] = abi.encodeWithSelector(
                IFeedRules.processCreatePost.selector,
                originalMsgSender,
                account,
                postParams,
                ruleSpecificDatas[i]
            );
        }
        _processRules(datas);
    }

    function processEditPost(
        address originalMsgSender,
        address account,
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
                account,
                postId,
                newPostParams,
                ruleSpecificDatas[i]
            );
        }
        _processRules(datas);
    }

    function processDeletePost(
        address originalMsgSender,
        address account,
        uint256 postId,
        bytes calldata data
    ) external {
        bytes[] memory ruleSpecificDatas = abi.decode(data, (bytes[]));
        bytes[] memory datas = new bytes[](_rules.length);
        for (uint256 i = 0; i < _rules.length; i++) {
            datas[i] = abi.encodeWithSelector(
                IFeedRules.processDeletePost.selector,
                originalMsgSender,
                account,
                postId,
                ruleSpecificDatas[i]
            );
        }
        _processRules(datas);
    }

    function processPostRulesChange(
        address originalMsgSender,
        address account,
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
                account,
                postId,
                newPostRules,
                ruleSpecificDatas[i]
            );
        }
        _processRules(datas);
    }
}
