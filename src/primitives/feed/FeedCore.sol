// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {PostParams} from './IFeed.sol';

struct PostStorage {
    address author;
    address source;
    string contentURI;
    string metadataURI;
    uint256[] quotedPostIds;
    uint256[] parentPostIds;
    address postRules;
    uint80 timestamp; // Passed-in by the author or client
    uint80 submissionTimestamp; // Automatically fetched from the block once submitted
    uint80 lastUpdatedTimestamp; // Automatically fetched from the block once updated
    mapping(bytes32 key => bytes value) extraData;
}

library FeedCore {
    // Storage
    struct Storage {
        address accessControl;
        string feedMetadataURI;
        address feedRules;
        uint256 postCount;
        mapping(uint256 postId => PostStorage post) posts;
    }

    // keccak256('lens.feed.core.storage')
    bytes32 constant CORE_STORAGE_SLOT = 0x53e5f3a14c02f725b39e2bf6437f59559b62f544e37322ca762304defb765d0e;

    function $storage() internal pure returns (Storage storage _storage) {
        assembly {
            _storage.slot := CORE_STORAGE_SLOT
        }
    }

    // External functions - Use these functions to be called through DELEGATECALL

    function createPost(PostParams calldata postParams) external returns (uint256) {
        return _createPost(postParams);
    }

    function editPost(uint256 postId, PostParams calldata postParams) external {
        _editPost(postId, postParams);
    }

    function deletePost(uint256 postId, bytes32[] calldata extraDataKeysToDelete) external {
        _deletePost(postId, extraDataKeysToDelete);
    }

    // Internal functions - Use these functions to be called as an inlined library

    function _createPost(PostParams calldata postParams) internal returns (uint256) {
        uint256 postId = ++$storage().postCount;
        PostStorage storage _newPost = $storage().posts[postId];
        _newPost.author = postParams.author;
        _newPost.source = postParams.source;
        _newPost.contentURI = postParams.contentURI;
        _newPost.metadataURI = postParams.metadataURI;
        _newPost.quotedPostIds = postParams.quotedPostIds;
        _newPost.parentPostIds = postParams.parentPostIds;
        _newPost.postRules = address(postParams.postRules); // TODO: Probably change to type address in PostParams struct
        _newPost.timestamp = postParams.timestamp;
        _newPost.submissionTimestamp = uint80(block.timestamp);
        _newPost.lastUpdatedTimestamp = uint80(block.timestamp);
        for (uint256 i = 0; i < postParams.extraData.length; i++) {
            _newPost.extraData[postParams.extraData[i].key] = postParams.extraData[i].value;
        }
        return postId;
    }

    function _editPost(uint256 postId, PostParams calldata postParams) internal {
        PostStorage storage _post = $storage().posts[postId];
        _post.author = postParams.author;
        _post.source = postParams.source; // TODO: Can you edit the source? you might be editing from a diff source than the original source...
        _post.contentURI = postParams.contentURI;
        _post.metadataURI = postParams.metadataURI;
        _post.quotedPostIds = postParams.quotedPostIds;
        _post.parentPostIds = postParams.parentPostIds;
        address currentPostRules = _post.postRules;
        if (address(currentPostRules) != address(postParams.postRules)) {
            // Basically, a hook is called in the rules, cause maybe the previous rules have some "immutable" flag!
            // currentPostRules.onRuleChanged(postId, postParams.postRules);
            // TODO: In the core we do not know interfaces of rules! It's made abstract, just addresses.
            // TODO: Maybe the immutability should be at the post-level, not rule-level...
            _post.postRules = address(postParams.postRules); // TODO: Probably change to type address in PostParams struct
        }
        _post.timestamp = postParams.timestamp;
        _post.lastUpdatedTimestamp = uint80(block.timestamp);
        for (uint256 i = 0; i < postParams.extraData.length; i++) {
            _post.extraData[postParams.extraData[i].key] = postParams.extraData[i].value;
        }
    }

    function _deletePost(uint256 postId, bytes32[] calldata extraDataKeysToDelete) internal {
        for (uint256 i = 0; i < extraDataKeysToDelete.length; i++) {
            delete $storage().posts[postId].extraData[extraDataKeysToDelete[i]];
        }
        delete $storage().posts[postId];
    }
}
