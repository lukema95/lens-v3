// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DataElement, RuleConfiguration, RuleExecutionData} from "../../types/Types.sol";
import {IMetadataBased} from "./../base/IMetadataBased.sol";
// TODO: Should we remove the ignored params for now? This will simplify the interface, but if somebody (or we) want
// to implement it later - we would have to break the interface to bring them back.

struct EditPostParams {
    address author; // TODO: This is ignored now (you cannot edit the author, so just pass anything)
    address source; // TODO: This is ignored now (you cannot edit the source, so just pass anything)
    string metadataURI;
    uint256[] quotedPostIds; // TODO: This is ignored now (you cannot edit the quotedPostIds, so just pass anything)
    uint256[] parentPostIds; // TODO: This is ignored now (you cannot edit the parentPostIds, so just pass anything)
    DataElement[] extraData;
}

struct CreatePostParams {
    address author; // Multiple authors can be added in extraData
    address source; // Client source, if any
    string metadataURI;
    uint256[] quotedPostIds;
    uint256[] parentPostIds;
    RuleConfiguration[] rules;
    RuleExecutionData feedRulesData;
    RuleExecutionData[] changeRulesQuotesPostRulesData; // TODO: This is getting really out of hand...
    RuleExecutionData[] changeRulesParentsPostRulesData; // TODO: But we don't have the luxury...
    RuleExecutionData[] quotesPostRulesData; // TODO: soooooo....
    RuleExecutionData[] parentsPostRulesData; // TODO: ...it is what it is (c) Peter
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
    address[] requiredRules;
    address[] anyOfRules;
    uint80 creationTimestamp;
    uint80 lastUpdatedTimestamp;
}

interface IFeed is IMetadataBased {
    event Lens_Feed_PostCreated(
        uint256 indexed postId, address indexed author, uint256 indexed localSequentialId, CreatePostParams postParams
    );

    event Lens_Feed_PostEdited(
        uint256 indexed postId, address indexed author, EditPostParams newPostParams, RuleExecutionData feedRulesData
    );

    event Lens_Feed_PostDeleted(uint256 indexed postId, address indexed author, RuleExecutionData feedRulesData);

    event Lens_Feed_ExtraDataSet(bytes32 indexed key, bytes value, bytes indexed valueIndexed);

    event Lens_Feed_RuleAdded(address indexed ruleAddress, bytes configData, bool indexed isRequired);
    event Lens_Feed_RuleUpdated(address indexed ruleAddress, bytes configData, bool indexed isRequired);
    event Lens_Feed_RuleRemoved(address indexed ruleAddress);

    event Lens_Feed_Post_RuleAdded(
        uint256 indexed postId, address indexed author, address indexed ruleAddress, bytes configData, bool isRequired
    );
    event Lens_Feed_Post_RuleUpdated(
        uint256 indexed postId, address indexed author, address indexed ruleAddress, bytes configData, bool isRequired
    );
    event Lens_Feed_Post_RuleRemoved(uint256 indexed postId, address indexed author, address indexed ruleAddress);

    function addFeedRules(RuleConfiguration[] calldata rules) external;

    function updateFeedRules(RuleConfiguration[] calldata rules) external;

    function removeFeedRules(address[] calldata rules) external;

    function createPost(CreatePostParams calldata postParams) external returns (uint256);

    function editPost(
        uint256 postId,
        EditPostParams calldata newPostParams,
        RuleExecutionData calldata editPostFeedRulesData
    ) external;

    // "Delete" - u know u cannot delete stuff from the internet, right? :]
    // But this will at least remove it from the current state, so contracts accesing it will know.
    function deletePost(
        uint256 postId,
        bytes32[] calldata extraDataKeysToDelete,
        RuleExecutionData calldata feedRulesData
    ) external;

    function addPostRules(
        uint256 postId,
        RuleConfiguration[] calldata rules,
        RuleExecutionData calldata feedRulesData,
        RuleExecutionData[] calldata quotesPostRulesData,
        RuleExecutionData[] calldata parentsPostRulesData
    ) external;

    function updatePostRules(
        uint256 postId,
        RuleConfiguration[] calldata rules,
        RuleExecutionData calldata feedRulesData,
        RuleExecutionData[] calldata quotesPostRulesData,
        RuleExecutionData[] calldata parentsPostRulesData
    ) external;

    function removePostRules(
        uint256 postId,
        RuleConfiguration[] calldata rules,
        RuleExecutionData calldata feedRulesData,
        RuleExecutionData[] calldata quotesPostRulesData,
        RuleExecutionData[] calldata parentsPostRulesData
    ) external;

    function setExtraData(DataElement[] calldata extraDataToSet) external;

    // Getters

    function getPost(uint256 postId) external view returns (Post memory);

    function getPostAuthor(uint256 postId) external view returns (address);

    function getFeedRules(bool isRequired) external view returns (address[] memory);

    function getPostRules(uint256 postId, bool isRequired) external view returns (address[] memory);

    function getPostCount() external view returns (uint256);

    function getPostExtraData(uint256 postId, bytes32 key) external view returns (bytes memory);

    function getExtraData(bytes32 key) external view returns (bytes memory);
}
