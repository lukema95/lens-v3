// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IFeedRules, PostParams, IPostRules} from 'src/primitives/feed/IFeedRules.sol';

library SourceLib {
    function transferFee(address source, address from, address someCoin, uint256 fee) internal {
        if (source != address(0)) {
            // Give a fee to the current source
            if (source.code.length > 0) {
                address sourceTreasury = ISource(source).getTreasury();
                IERC20(someCoin).safeTransferFrom(from, sourceTreasury, fee);
            } else {
                IERC20(someCoin).safeTransferFrom(from, source, fee); // Who pays? originalMsgSender, author or what
            }
        }
    }
}

contract SomeFeedRule is IFeedRules {
    using SourceLib for address;

    function processCreatePost(
        address originalMsgSender,
        uint256 postId,
        PostParams calldata postParams,
        bytes calldata data
    ) external override {
        // Let's say they need to pay to post, and this is being set as a global rule with this rule
        // if (postParams.source != address(0)) {
        //     // Give a fee to the current source
        //     if (postParams.source.code.length > 0) {
        //         address sourceTreasury = ISource(postParams.source).getTreasury();
        //         IERC20(someCoin).safeTransferFrom(postParams.author, sourceTreasury, fee);
        //     } else {
        //         IERC20(someCoin).safeTransferFrom(postParams.author, postParams.source, fee); // Who pays? originalMsgSender, author or what
        //     }
        // }
        postParams.source.transferFee(postParams.author, postParams.someCoin, postParams.fee);

        if (postParams.parentPostIds.length > 0) {
            // Will you go through the parents and give a fee to those sources?
        }
        if (postParams.quotedPostIds.length > 0) {
            // Will you go through the quoted posts and give a fee to those sources?
        }
    }

    function processEditPost(
        address originalMsgSender,
        uint256 postId,
        PostParams calldata newPostParams,
        bytes calldata data
    ) external override {}

    function processDeletePost(address originalMsgSender, uint256 postId, bytes calldata data) external override {}

    function processPostRulesChange(
        address originalMsgSender,
        uint256 postId,
        IPostRules newPostRules,
        bytes calldata data
    ) external override {}
}
