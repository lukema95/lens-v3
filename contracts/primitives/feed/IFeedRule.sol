// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IPostRule} from "./IPostRule.sol";
import {PostParams} from "./IFeed.sol";

interface IFeedRule {
    function configure(bytes calldata data) external;

    function processCreatePost(
        uint256 postId,
        uint256 localSequentialId,
        PostParams calldata postParams,
        bytes calldata data
    ) external;

    function processEditPost(
        uint256 postId,
        uint256 localSequentialId,
        PostParams calldata newPostParams,
        bytes calldata data
    ) external;

    function processDeletePost(uint256 postId, uint256 localSequentialId, bytes calldata feedRulesData) external;

    function processPostRulesChange(
        uint256 postId,
        uint256 localSequentialId,
        address[] newPostRules,
        bytes calldata data
    ) external;

    // TODO: Do we need these global quote/parent rules? Or they exist only per-post?
    // function processQuotes
    // function processParents
}
