// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IPostRules} from './IPostRules.sol';
import {PostParams} from './IFeed.sol';

interface IFeedRules {
    function processCreatePost(
        address originalMsgSender,
        uint256 postId,
        PostParams calldata postParams,
        bytes calldata data
    ) external;

    function processEditPost(
        address originalMsgSender,
        uint256 postId,
        PostParams calldata newPostParams,
        bytes calldata data
    ) external;

    function processDeletePost(address originalMsgSender, uint256 postId, bytes calldata data) external;

    function processPostRulesChange(
        address originalMsgSender,
        uint256 postId,
        IPostRules newPostRules,
        bytes calldata data
    ) external;

    // TODO: Do we need these global quote/parent rules? Or they exist only per-post?
    // function processQuotes
    // function processParents
}
