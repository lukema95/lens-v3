// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// TODO: We do not have native referrals here, shoud we add them?
interface IPostRule {
    function configure(uint256 postId, bytes calldata data) external;

    function processQuote(uint256 rootPostId, uint256 quotedPostId, uint256 postId, bytes calldata data) external;

    function processReply(uint256 rootPostId, uint256 repliedPostId, uint256 postId, bytes calldata data) external;

    function processRepost(uint256 rootPostId, uint256 repostedPostId, uint256 postId, bytes calldata data) external;
}
