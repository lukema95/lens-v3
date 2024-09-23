// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IFeed, Post, PostParams} from "./IFeed.sol";
import {IFeedRule} from "./IFeedRule.sol";
import {FeedCore as Core} from "./FeedCore.sol";
import {IPostRule} from "./../feed/IPostRule.sol";
import {IAccessControl} from "./../access-control/IAccessControl.sol";
import {AccessControlLib} from "./../libraries/AccessControlLib.sol";
import {DataElement} from "./../../types/Types.sol";
import {RuleBasedFeed} from "./RuleBasedFeed.sol";
import {AccessControlled} from "./../base/AccessControlled.sol";

contract Feed is IFeed, RuleBasedFeed, AccessControlled {
    // Resource IDs involved in the contract
    uint256 constant SET_RULES_RID = uint256(keccak256("SET_RULES"));
    uint256 constant SET_METADATA_RID = uint256(keccak256("SET_METADATA"));
    uint256 constant DELETE_POST_RID = uint256(keccak256("DELETE_POST"));
    uint256 constant SET_EXTRA_DATA_RID = uint256(keccak256("SET_EXTRA_DATA"));
    uint256 constant CHANGE_ACCESS_CONTROL_RID = uint256(keccak256("CHANGE_ACCESS_CONTROL"));

    constructor(string memory metadataURI, IAccessControl accessControl) AccessControlled(accessControl) {
        Core.$storage().metadataURI = metadataURI;
        emit Lens_Feed_MetadataUriSet(metadataURI);
    }

    // Access Controlled functions

    function addFeedRules(RuleConfiguration[] calldata rules) external override {
        _requireAccess(msg.sender, SET_RULES_RID);
        for (uint256 i = 0; i < rules.length; i++) {
            _addFeedRule(rules[i]);
            emit Lens_Feed_RuleAdded(rules[i].ruleAddress, rules[i].configData, rules[i].isRequired);
        }
    }

    function updateFeedRules(RuleConfiguration[] calldata rules) external override {
        _requireAccess(msg.sender, SET_RULES_RID);
        for (uint256 i = 0; i < rules.length; i++) {
            _updateFeedRule(rules[i]);
            emit Lens_Feed_RuleUpdated(rules[i].ruleAddress, rules[i].configData, rules[i].isRequired);
        }
    }

    function removeFeedRules(address[] calldata rules) external override {
        _requireAccess(msg.sender, SET_RULES_RID);
        for (uint256 i = 0; i < rules.length; i++) {
            _removeFeedRule(rules[i]);
            emit Lens_Feed_RuleRemoved(rules[i]);
        }
    }

    // Public user functions

    function createPost(PostParams calldata postParams, RuleExecutionData calldata feedRulesData)
        external
        override
        returns (uint256)
    {
        require(msg.sender == postParams.author);
        (uint256 postId, uint256 localSequentialId) = Core._createPost(postParams);
        _feedProcessCreatePost(postId, localSequentialId, postParams, feedRulesData);
        emit Lens_Feed_PostCreated(postId, postParams.author, localSequentialId, postParams, feedRulesData);
        return postId;
    }

    function editPost(
        uint256 postId,
        PostParams calldata newPostParams,
        RuleExecutionData calldata editPostFeedRulesData,
        RuleExecutionData calldata postRulesChangeFeedRulesData
    ) external override {
        address author = Core.$storage().posts[postId].author;
        // TODO: We can have this for moderators:
        // require(msg.sender == author || _hasAccess(msg.sender, EDIT_POST_RID));
        require(msg.sender == author);
        _feedProcessEditPost(postId, newPostParams, editPostFeedRulesData);
        Core._editPost(postId, newPostParams);
        emit Lens_Feed_PostEdited(postId, author, newPostParams, editPostFeedRulesData, postRulesChangeFeedRulesData);
    }

    function deletePost(
        uint256 postId,
        bytes32[] calldata extraDataKeysToDelete,
        RuleExecutionData calldata feedRulesData
    ) external override {
        address author = Core.$storage().posts[postId].author;
        require(msg.sender == author || _hasAccess(msg.sender, DELETE_POST_RID));
        _feedProcessDeletePost(postId, Core.$storage().posts[postId].localSequentialId, feedRulesData);
        Core._deletePost(postId);
        emit Lens_Feed_PostDeleted(postId, author, feedRulesData);
    }

    function addPostRules(RuleConfiguration[] calldata rules) external override {
        if (address(newPostParams.postRules) != Core.$storage().posts[postId].postRules) {
            _feedProcessPostRulesChange(author, postId, newPostParams.postRules, postRulesChangeFeedRulesData);
        }
    }

    function removePostRules(RuleConfiguration[] calldata rules) external override {}

    function setExtraData(DataElement[] calldata extraDataToSet) external override {
        Core.$storage().accessControl.requireAccess(msg.sender, SET_EXTRA_DATA_RID);
        Core._setExtraData(extraDataToSet);
        for (uint256 i = 0; i < extraDataToSet.length; i++) {
            emit Lens_Feed_ExtraDataSet(extraDataToSet[i].key, extraDataToSet[i].value, extraDataToSet[i].value);
        }
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
