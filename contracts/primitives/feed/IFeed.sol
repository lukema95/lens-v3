// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IPostRule} from "./IPostRule.sol";
import {IFeedRule} from "./IFeedRule.sol";
import {IAccessControl} from "../access-control/IAccessControl.sol";
import {DataElement} from "../../types/Types.sol";

struct PostParams {
    address author; // Multiple authors can be added in extraData
    address source; // Client source, if any
    string metadataURI;
    uint256[] quotedPostIds;
    uint256[] parentPostIds;
    // IPostRule postRules; // TODO: Do we even this now? Rules are stored in $storage now (see Graph and FollowRules)
    DataElement[] extraData;
}

// This is a return type (for getters)
struct Post {
    address author;
    uint256 localSequentialId;
    address source;
    string metadataURI;
    uint256[] quotedPostIds;
    uint256[] parentPostIds;
    // IPostRule postRules; // TODO: Do we even this now? Rules are stored in $storage now (see Graph and FollowRules)
    uint80 creationTimestamp;
    uint80 lastUpdatedTimestamp;
}

interface IFeed {
    event Lens_Feed_MetadataUriSet(string metadataURI);

    event Lens_Feed_PostCreated(
        uint256 indexed postId,
        address indexed author,
        uint256 indexed localSequentialId,
        PostParams postParams,
        RuleExecutionData feedRulesData
    );

    event Lens_Feed_PostEdited(
        uint256 indexed postId,
        address indexed author,
        PostParams newPostParams,
        RuleExecutionData feedRulesData,
        RuleExecutionData postRulesChangeFeedRulesData
    );

    event Lens_Feed_PostDeleted(uint256 indexed postId, address indexed author, RuleExecutionData feedRulesData);

    event Lens_Feed_RulesSet(address indexed feedRules);

    event Lens_Feed_ExtraDataSet(bytes32 indexed key, bytes value, bytes indexed valueIndexed);

    function addFeedRules(RuleConfiguration[] calldata rules) external;

    function updateFeedRules(RuleConfiguration[] calldata rules) external;

    function removeFeedRules(address[] calldata rules) external;

    function createPost(PostParams calldata postParams, RuleExecutionData calldata feedRulesData)
        external
        returns (uint256);

    function editPost(
        uint256 postId,
        PostParams calldata newPostParams,
        RuleExecutionData calldata editPostFeedRulesData,
        RuleExecutionData calldata postRulesChangeFeedRulesData
    ) external;

    // "Delete" - u know u cannot delete stuff from the internet, right? :]
    // But this will at least remove it from the current state, so contracts accesing it will know.
    function deletePost(
        uint256 postId,
        bytes32[] calldata extraDataKeysToDelete,
        RuleExecutionData calldata feedRulesData
    ) external;

    function setExtraData(DataElement[] calldata extraDataToSet) external;

    // Getters

    function getPost(uint256 postId) external view returns (Post memory);

    function getPostAuthor(uint256 postId) external view returns (address);

    function getFeedRules() external view returns (IFeedRule);

    function getPostRules(uint256 postId) external view returns (IPostRule);

    function getPostCount() external view returns (uint256);

    function getFeedMetadataURI() external view returns (string memory);

    function getPostExtraData(uint256 postId, bytes32 key) external view returns (bytes memory);

    function getExtraData(bytes32 key) external view returns (bytes memory);
}
