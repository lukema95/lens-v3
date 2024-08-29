// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IPostRule} from './IPostRule.sol';
import {IFeedRule} from './IFeedRule.sol';
import {IAccessControl} from '../access-control/IAccessControl.sol';

/*
    TODO: Natspec
    
    // extraData - arbitrary key-value storage

    >> 1. pass extraData(name, value)
        2. store value at "name" somehow
        3. anyone can go to post and ask for "name" to get the value (or get 0 or "" or smth if not set)

    Example:
        mapping(uint256 postId => mapping(bytes32 (keccak256(name)) => bytes abi.encoded(value) or "" empty bytes)
*/

struct DataElement {
    bytes32 key;
    bytes value;
}

struct PostParams {
    address author; // Multiple authors can be added in extraData
    address source; // Client source, if any
    string contentURI; // We have these separate, because: "You might want to store content on IPFS..."
    string metadataURI; // "...but metadata on a S3 server"
    uint256[] quotedPostIds;
    uint256[] parentPostIds;
    IPostRule postRules;
    uint80 timestamp;
    DataElement[] extraData;
}

// This is a return type (for getters)
struct Post {
    address author;
    address source;
    string contentURI;
    string metadataURI;
    uint256[] quotedPostIds;
    uint256[] parentPostIds;
    IPostRule postRules;
    uint80 timestamp; // Passed-in by the author or client
    uint80 submissionTimestamp; // Automatically fetched from the block once submitted
    uint80 lastUpdatedTimestamp; // Automatically fetched from the block once updated
}

interface IFeed {
    event Lens_Feed_PostCreated(uint256 indexed postId, PostParams postParams, bytes feedRulesData, uint256 postTypeId);

    event Lens_Feed_PostEdited(
        uint256 indexed postId,
        PostParams newPostParams,
        bytes feedRulesData,
        bytes postRulesChangeFeedRulesData,
        uint256 postTypeId
    );

    event Lens_Feed_PostDeleted(uint256 indexed postId, bytes feedRulesData);

    event Lens_Feed_RulesSet(address feedRules);

    function createPost(PostParams calldata postParams, bytes calldata data) external returns (uint256);

    function editPost(
        uint256 postId,
        PostParams calldata newPostParams,
        bytes calldata editPostFeedRulesData,
        bytes calldata postRulesChangeFeedRulesData
    ) external;

    // "Delete" - u know u cannot delete stuff from the internet, right? :]
    // But this will at least remove it from the current state, so contracts accesing it will know.
    function deletePost(
        uint256 postId,
        bytes32[] calldata extraDataKeysToDelete,
        bytes calldata feedRulesData
    ) external;

    function setFeedRules(IFeedRule feedRules) external;

    // Getters

    function getPost(uint256 postId) external view returns (Post memory);

    function getPostTypeId(uint256 postId) external view returns (uint8);

    function getPostAuthor(uint256 postId) external view returns (address);

    function getFeedRules() external view returns (IFeedRule);

    function getPostRules(uint256 postId) external view returns (IPostRule);

    function getPostCount() external view returns (uint256);

    function getFeedMetadataURI() external view returns (string memory);

    function getAccessControl() external view returns (IAccessControl);
}
