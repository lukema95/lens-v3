// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IFeed, Post, PostParams} from "./IFeed.sol";
import {IFeedRule} from "./IFeedRule.sol";
import {FeedCore as Core} from "./FeedCore.sol";
import {IPostRule} from "./../feed/IPostRule.sol";
import {IAccessControl} from "./../access-control/IAccessControl.sol";

contract Feed is IFeed {
    // Resource IDs involved in the contract
    uint256 constant SET_RULES_RID = uint256(keccak256("SET_RULES"));
    uint256 constant SET_METADATA_RID = uint256(keccak256("SET_METADATA"));
    uint256 constant DELETE_POST_RID = uint256(keccak256("DELETE_POST"));
    uint256 constant CHANGE_ACCESS_CONTROL_RID = uint256(keccak256("CHANGE_ACCESS_CONTROL"));

    constructor(string memory metadataURI, IAccessControl accessControl) {
        Core.$storage().metadataURI = metadataURI;
        Core.$storage().accessControl = address(accessControl);
        emit Lens_Feed_MetadataUriSet(metadataURI);
    }

    // Access Controlled functions

    function setFeedRules(IFeedRule feedRules) external override {
        require(
            IAccessControl(Core.$storage().accessControl).hasAccess({
                account: msg.sender,
                resourceLocation: address(this),
                resourceId: SET_RULES_RID
            })
        );
        Core.$storage().feedRules = address(feedRules);
        emit Lens_Feed_RulesSet(address(feedRules));
    }

    // TODO: This is a 1-step operation, while some of our AC owner transfers are a 2-step, or even 3-step operations.
    function setAccessControl(IAccessControl accessControl) external {
        require(
            IAccessControl(Core.$storage().accessControl).hasAccess({
                account: msg.sender,
                resourceLocation: address(this),
                resourceId: CHANGE_ACCESS_CONTROL_RID
            })
        ); // msg.sender must have permissions to change access control
        accessControl.hasAccess(address(0), address(0), 0); // We expect this to not panic.
        Core.$storage().accessControl = address(accessControl);
    }

    // Public user functions

    function createPost(PostParams calldata postParams, bytes calldata feedRulesData)
        external
        override
        returns (uint256)
    {
        require(msg.sender == postParams.author);
        uint256 postId = Core._createPost(postParams);
        if (address(Core.$storage().feedRules) != address(0)) {
            IFeedRule(Core.$storage().feedRules).processCreatePost(msg.sender, postId, postParams, feedRulesData);
        }
        emit Lens_Feed_PostCreated(postId, postParams, feedRulesData, _getPostTypeId(postParams));
        return postId;
    }

    function editPost(
        uint256 postId,
        PostParams calldata newPostParams,
        bytes calldata editPostFeedRulesData,
        bytes calldata postRulesChangeFeedRulesData
    ) external override {
        require(msg.sender == Core.$storage().posts[postId].author);
        if (address(Core.$storage().feedRules) != address(0)) {
            IFeedRule(Core.$storage().feedRules).processEditPost(
                msg.sender, postId, newPostParams, editPostFeedRulesData
            );
        }
        if (address(newPostParams.postRules) != Core.$storage().posts[postId].postRules) {
            IFeedRule(Core.$storage().feedRules).processPostRulesChange(
                msg.sender, postId, newPostParams.postRules, postRulesChangeFeedRulesData
            );
        }
        Core._editPost(postId, newPostParams);
        emit Lens_Feed_PostEdited(
            postId, newPostParams, editPostFeedRulesData, postRulesChangeFeedRulesData, _getPostTypeId(newPostParams)
        );
    }

    // TODO: How we decided to do moderation (moderator is able to delete spam posts, skipping an author check):
    /*

    */

    function deletePost(uint256 postId, bytes32[] calldata extraDataKeysToDelete, bytes calldata feedRulesData)
        external
        override
    {
        if (msg.sender != Core.$storage().posts[postId].author) {
            require(_canDeletePost(msg.sender));
        }
        if (address(Core.$storage().feedRules) != address(0)) {
            IFeedRule(Core.$storage().feedRules).processDeletePost(msg.sender, postId, feedRulesData);
        }
        Core._deletePost(postId, extraDataKeysToDelete);
        emit Lens_Feed_PostDeleted(postId, feedRulesData);
    }

    function _canDeletePost(address account) internal virtual returns (bool) {
        return IAccessControl(Core.$storage().accessControl).hasAccess({
            account: account,
            resourceLocation: address(this),
            resourceId: DELETE_POST_RID
        });
    }

    enum Cardinality {
        NONE,
        ONE,
        MANY
    }

    function _getPostTypeId(PostParams memory post) internal pure returns (uint8) {
        // Probably better with an enum: { NONE, ONE, MANY }
        Cardinality metadataURICardinality = bytes(post.metadataURI).length > 0 ? Cardinality.ONE : Cardinality.NONE;
        Cardinality quotedPostCardinality = post.quotedPostIds.length > 0
            ? (post.quotedPostIds.length > 1 ? Cardinality.MANY : Cardinality.ONE)
            : Cardinality.NONE;
        Cardinality parentPostCardinality = post.parentPostIds.length > 0
            ? (post.parentPostIds.length > 1 ? Cardinality.MANY : Cardinality.ONE)
            : Cardinality.NONE;

        /*
        We use 5 bits to encode the post type:
        00 00  0
         ^  ^  ^
         ^  ^  ^ 
         ^  ^  ^
         ^  ^  contentURICardinality
         ^  ^
         ^  quotedPostCardinality
         ^
         parentPostCardinality

        It will have some gaps, but it's easy to encode/decode by shifting bits.
        */
        uint8 postType =
            uint8(metadataURICardinality) | (uint8(quotedPostCardinality) << 1) | (uint8(parentPostCardinality) << 3);

        return postType;
    }

    // Getters

    function getPost(uint256 postId) external view override returns (Post memory) {
        return Post({
            author: Core.$storage().posts[postId].author,
            source: Core.$storage().posts[postId].source,
            metadataURI: Core.$storage().posts[postId].metadataURI,
            quotedPostIds: Core.$storage().posts[postId].quotedPostIds,
            parentPostIds: Core.$storage().posts[postId].parentPostIds,
            postRules: IPostRule(Core.$storage().posts[postId].postRules),
            creationTimestamp: Core.$storage().posts[postId].creationTimestamp,
            lastUpdatedTimestamp: Core.$storage().posts[postId].lastUpdatedTimestamp
        });
    }

    function getPostTypeId(uint256 postId) external view returns (uint8) {
        PostParams memory post;
        post.quotedPostIds = Core.$storage().posts[postId].quotedPostIds;
        post.parentPostIds = Core.$storage().posts[postId].parentPostIds;
        return _getPostTypeId(post);
    }

    function getPostAuthor(uint256 postId) external view override returns (address) {
        return Core.$storage().posts[postId].author;
    }

    function getFeedRules() external view override returns (IFeedRule) {
        return IFeedRule(Core.$storage().feedRules);
    }

    function getPostRules(uint256 postId) external view override returns (IPostRule) {
        return IPostRule(Core.$storage().posts[postId].postRules);
    }

    function getPostCount() external view override returns (uint256) {
        return Core.$storage().postCount;
    }

    function getFeedMetadataURI() external view override returns (string memory) {
        return Core.$storage().metadataURI;
    }

    function getAccessControl() external view override returns (IAccessControl) {
        return IAccessControl(Core.$storage().accessControl);
    }
}
