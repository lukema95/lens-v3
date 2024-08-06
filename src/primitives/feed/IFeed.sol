// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IPostRules} from './IPostRules.sol';

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
    string contentURI; // We have these separate, because: "You might want to store content on IPFS..."
    string metadataURI; // "...but metadata on a S3 server"
    uint256[] quotedPostIds;
    uint256[] parentPostIds;
    IPostRules postRules;
    uint80 timestamp;
    DataElement[] extraData;
}

// This is a return type (for getters)
struct Post {
    address author;
    string contentURI;
    string metadataURI;
    uint256[] quotedPostIds;
    uint256[] parentPostIds;
    IPostRules postRules;
    uint80 timestamp; // Passed-in by the author or client
    uint80 submissionTimestamp; // Automatically fetched from the block once submitted
    uint80 lastUpdatedTimestamp; // Automatically fetched from the block once updated
}

interface IFeed {
    event PostCreated(uint256 indexed postId, PostParams postParams, bytes feedRulesData, uint256 postTypeId);

    event PostEdited(
        uint256 indexed postId,
        PostParams newPostParams,
        bytes feedRulesData,
        bytes postRulesChangeFeedRulesData,
        uint256 postTypeId
    );

    event PostDeleted(uint256 indexed postId, bytes feedRulesData);

    function post(PostParams calldata postParams, bytes calldata data) external returns (uint256);

    function editPost(uint256 postId, PostParams calldata updatedPostParams, bytes calldata data) external;

    // "Delete" - u know u cannot delete stuff from the internet, right? :]
    // But this will at least remove it from the current state, so contracts accesing it will know.
    function deletePost(uint256 postId, bytes calldata data) external;
}
