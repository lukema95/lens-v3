// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IFeedRule} from "./../primitives/feed/IFeedRule.sol";
import {IGraphRule} from "./../primitives/graph/IGraphRule.sol";
import {CreatePostParams, EditPostParams} from "./../primitives/feed/IFeed.sol";
import {RuleConfiguration} from "./../types/Types.sol";
import {IFeed} from "./../primitives/feed/IFeed.sol";

contract UserBlocking is IFeedRule, IGraphRule {
    event Lens_UserBlocking_UserBlocked(address indexed source, address indexed target, uint256 timestamp);
    event Lens_UserBlocking_UserUnblocked(address indexed source, address indexed target);

    mapping(address blockSource => mapping(address blockTarget => uint256 blockedTimestamp)) public userBlocks;

    function configure(bytes calldata /*data*/ ) external pure override(IFeedRule, IGraphRule) {
        revert();
    }

    function blockUser(address source, address target) external {
        require(msg.sender == source, "Only the source can block a user");
        require(source != target, "Cannot block self");
        userBlocks[source][target] = block.timestamp;
    }

    function unblockUser(address source, address target) external {
        require(msg.sender == source, "Only the source can unblock a user");
        userBlocks[msg.sender][target] = 0;
    }

    function processCreatePost(
        uint256 postId,
        uint256, /* localSequentialId */
        CreatePostParams calldata postParams,
        bytes calldata /* data */
    ) external view returns (bool) {
        if (postParams.repliedPostId != 0) {
            address author = postParams.author;
            address repliedToAuthor = IFeed(msg.sender).getPostAuthor(postParams.repliedPostId);
            uint256 rootPostId = IFeed(msg.sender).getPost(postId).rootPostId;
            address rootAuthor = IFeed(msg.sender).getPostAuthor(rootPostId);
            if (_isBlocked({source: repliedToAuthor, blockTarget: author})) {
                revert("User is blocked from replying to this user");
            }
            if (_isBlocked({source: rootAuthor, blockTarget: author})) {
                revert("User is blocked from commenting on this author's posts");
            }
        }
        return true;
    }

    function processFollow(
        address followerAcount,
        address accountToFollow,
        uint256, /* followId */
        bytes calldata /* data */
    ) external view returns (bool) {
        if (_isBlocked({source: accountToFollow, blockTarget: followerAcount})) {
            revert("User is blocked from following this user");
        }
        return true;
    }

    function isBlocked(address source, address blockTarget) external view returns (bool) {
        return _isBlocked(source, blockTarget);
    }

    function _isBlocked(address source, address blockTarget) internal view returns (bool) {
        return userBlocks[source][blockTarget] > 0;
    }

    // Unimplemented functions

    function processEditPost(
        uint256, /* postId */
        uint256, /* localSequentialId */
        EditPostParams calldata, /* editPostParams */
        bytes calldata /* data */
    ) external pure returns (bool) {
        return false;
    }

    function processDeletePost(uint256, /* postId */ uint256, /* localSequentialId */ bytes calldata /* data */ )
        external
        pure
        returns (bool)
    {
        return false;
    }

    function processPostRulesChanged(
        uint256, /* postId */
        uint256, /* localSequentialId */
        RuleConfiguration[] calldata, /* newPostRules */
        bytes calldata /* data */
    ) external pure returns (bool) {
        return false;
    }

    function processUnfollow(
        address, /* unfollowerAccount */
        address, /* accountToUnfollow */
        uint256, /* followId */
        bytes calldata /* data */
    ) external pure returns (bool) {
        return false;
    }

    function processFollowRulesChange(
        address, /* account */
        RuleConfiguration[] calldata, /* followRules */
        bytes calldata /* data */
    ) external pure returns (bool) {
        return false;
    }
}
