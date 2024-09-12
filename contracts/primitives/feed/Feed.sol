// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IFeed, Post, PostParams} from "./IFeed.sol";
import {IFeedRule} from "./IFeedRule.sol";
import {FeedCore as Core} from "./FeedCore.sol";
import {IPostRule} from "./../feed/IPostRule.sol";
import {IAccessControl} from "./../access-control/IAccessControl.sol";
import {AccessControlLib} from "./../libraries/AccessControlLib.sol";
import {DataElement} from "./../../types/Types.sol";

contract Feed is IFeed {
    using AccessControlLib for IAccessControl;
    using AccessControlLib for address;

    // Resource IDs involved in the contract
    uint256 constant SET_RULES_RID = uint256(keccak256("SET_RULES"));
    uint256 constant SET_METADATA_RID = uint256(keccak256("SET_METADATA"));
    uint256 constant DELETE_POST_RID = uint256(keccak256("DELETE_POST"));
    uint256 constant SET_EXTRA_DATA_RID = uint256(keccak256("SET_EXTRA_DATA"));
    uint256 constant CHANGE_ACCESS_CONTROL_RID = uint256(keccak256("CHANGE_ACCESS_CONTROL"));

    constructor(string memory metadataURI, IAccessControl accessControl) {
        Core.$storage().metadataURI = metadataURI;
        Core.$storage().accessControl = address(accessControl);
        emit Lens_Feed_MetadataUriSet(metadataURI);
    }

    // Access Controlled functions

    function setFeedRules(IFeedRule feedRules) external override {
        Core.$storage().accessControl.requireAccess(msg.sender, SET_RULES_RID);
        Core.$storage().feedRules = address(feedRules);
        emit Lens_Feed_RulesSet(address(feedRules));
    }

    // TODO: This is a 1-step operation, while some of our AC owner transfers are a 2-step, or even 3-step operations.
    function setAccessControl(IAccessControl accessControl) external {
        // msg.sender must have permissions to change access control
        Core.$storage().accessControl.requireAccess(msg.sender, CHANGE_ACCESS_CONTROL_RID);
        accessControl.verifyHasAccessFunction();
        Core.$storage().accessControl = address(accessControl);
    }

    // Public user functions

    function createPost(PostParams calldata postParams, bytes calldata feedRulesData)
        external
        override
        returns (uint256)
    {
        require(msg.sender == postParams.author);
        (uint256 postId, uint256 localSequentialId) = Core._createPost(postParams);
        if (address(Core.$storage().feedRules) != address(0)) {
            IFeedRule(Core.$storage().feedRules).processCreatePost(msg.sender, postId, postParams, feedRulesData);
        }
        emit Lens_Feed_PostCreated(postId, postParams.author, localSequentialId, postParams, feedRulesData);
        return postId;
    }

    function editPost(
        uint256 postId,
        PostParams calldata newPostParams,
        bytes calldata editPostFeedRulesData,
        bytes calldata postRulesChangeFeedRulesData
    ) external override {
        address author = Core.$storage().posts[postId].author;
        require(msg.sender == author);
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
        emit Lens_Feed_PostEdited(postId, author, newPostParams, editPostFeedRulesData, postRulesChangeFeedRulesData);
    }

    function deletePost(uint256 postId, bytes32[] calldata extraDataKeysToDelete, bytes calldata feedRulesData)
        external
        override
    {
        address author = Core.$storage().posts[postId].author;
        if (msg.sender != author) {
            require(_canDeletePost(msg.sender));
        }
        if (address(Core.$storage().feedRules) != address(0)) {
            IFeedRule(Core.$storage().feedRules).processDeletePost(msg.sender, postId, feedRulesData);
        }
        Core._deletePost(postId, extraDataKeysToDelete);
        emit Lens_Feed_PostDeleted(postId, author, feedRulesData);
    }

    function setExtraData(DataElement[] calldata extraDataToSet) external override {
        Core.$storage().accessControl.requireAccess(msg.sender, SET_EXTRA_DATA_RID);
        Core._setExtraData(extraDataToSet);
        for (uint256 i = 0; i < extraDataToSet.length; i++) {
            emit Lens_Feed_ExtraDataSet(extraDataToSet[i].key, extraDataToSet[i].value, extraDataToSet[i].value);
        }
    }

    // TODO: Is this for moderators?
    function _canDeletePost(address account) internal virtual returns (bool) {
        return IAccessControl(Core.$storage().accessControl).hasAccess({
            account: account,
            resourceLocation: address(this),
            resourceId: DELETE_POST_RID
        });
    }

    // Getters

    function getPost(uint256 postId) external view override returns (Post memory) {
        return Post({
            author: Core.$storage().posts[postId].author,
            localSequentialId: Core.$storage().posts[postId].localSequentialId,
            source: Core.$storage().posts[postId].source,
            metadataURI: Core.$storage().posts[postId].metadataURI,
            quotedPostIds: Core.$storage().posts[postId].quotedPostIds,
            parentPostIds: Core.$storage().posts[postId].parentPostIds,
            postRules: IPostRule(Core.$storage().posts[postId].postRules),
            creationTimestamp: Core.$storage().posts[postId].creationTimestamp,
            lastUpdatedTimestamp: Core.$storage().posts[postId].lastUpdatedTimestamp
        });
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

    function getPostExtraData(uint256 postId, bytes32 key) external view override returns (bytes memory) {
        return Core.$storage().posts[postId].extraData[key];
    }

    function getAccessControl() external view override returns (IAccessControl) {
        return IAccessControl(Core.$storage().accessControl);
    }

    function getExtraData(bytes32 key) external view override returns (bytes memory) {
        return Core.$storage().extraData[key];
    }
}
