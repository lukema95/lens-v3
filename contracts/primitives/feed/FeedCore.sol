// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {PostParams} from "./IFeed.sol";
import "../libraries/ExtraDataLib.sol";

struct PostStorage {
    address author;
    uint256 localSequentialId;
    address source;
    string metadataURI;
    uint256[] quotedPostIds;
    uint256[] parentPostIds;
    address postRules;
    uint80 creationTimestamp;
    uint80 lastUpdatedTimestamp;
    mapping(bytes32 => bytes) extraData;
}

library FeedCore {
    using ExtraDataLib for mapping(bytes32 => bytes);

    // Storage

    struct Storage {
        address accessControl;
        string metadataURI;
        address feedRules;
        uint256 postCount;
        mapping(uint256 => PostStorage) posts;
        mapping(bytes32 => bytes) extraData;
    }

    // keccak256('lens.feed.core.storage')
    bytes32 constant CORE_STORAGE_SLOT = 0x53e5f3a14c02f725b39e2bf6437f59559b62f544e37322ca762304defb765d0e;

    function $storage() internal pure returns (Storage storage _storage) {
        assembly {
            _storage.slot := CORE_STORAGE_SLOT
        }
    }

    // External functions - Use these functions to be called through DELEGATECALL

    function createPost(PostParams calldata postParams) external returns (uint256, uint256) {
        return _createPost(postParams);
    }

    function editPost(uint256 postId, PostParams calldata postParams) external {
        _editPost(postId, postParams);
    }

    function deletePost(uint256 postId, bytes32[] calldata extraDataKeysToDelete) external {
        _deletePost(postId, extraDataKeysToDelete);
    }

    function setExtraData(DataElement[] calldata extraDataToSet) external {
        $storage().extraData.set(extraDataToSet);
    }

    // Internal functions - Use these functions to be called as an inlined library

    function _generatePostId(uint256 localSequentialId) internal view returns (uint256) {
        return uint256(keccak256(abi.encode("evm:", block.chainid, address(this), localSequentialId)));
    }

    function _createPost(PostParams calldata postParams) internal returns (uint256, uint256) {
        uint256 localSequentialId = ++$storage().postCount;
        uint256 postId = _generatePostId(localSequentialId);
        PostStorage storage _newPost = $storage().posts[postId];
        _newPost.author = postParams.author;
        _newPost.localSequentialId = localSequentialId;
        _newPost.source = postParams.source;
        _newPost.metadataURI = postParams.metadataURI;
        _newPost.quotedPostIds = postParams.quotedPostIds;
        _newPost.parentPostIds = postParams.parentPostIds;
        _newPost.postRules = address(postParams.postRules); // TODO: Probably change to type address in PostParams struct
        _newPost.creationTimestamp = uint80(block.timestamp);
        _newPost.lastUpdatedTimestamp = uint80(block.timestamp);
        _newPost.extraData.set(postParams.extraData);
        return (postId, localSequentialId);
    }

    function _editPost(uint256 postId, PostParams calldata postParams) internal {
        PostStorage storage _post = $storage().posts[postId];
        _post.author = postParams.author; // TODO: Author can be changed? NO, we should remove that, or add a require
        _post.source = postParams.source; // TODO: Can you edit the source? you might be editing from a diff source than the original source...
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
        _post.lastUpdatedTimestamp = uint80(block.timestamp);
        ExtraDataLib._setExtraData(_post.extraData, postParams.extraData);
    }

    function _deletePost(uint256 postId, bytes32[] calldata extraDataKeysToDelete) internal {
        for (uint256 i = 0; i < extraDataKeysToDelete.length; i++) {
            delete $storage().posts[postId].extraData[extraDataKeysToDelete[i]];
        }
        delete $storage().posts[postId];
    }

    // TODO: Debate this more. It should be a soft delete, you can reconstruct anyways from tx history.
    // function _disablePost(uint256 postId) internal {
    //      $storage().posts[postId].disabled = true;
    // }

    function _setExtraData(DataElement[] calldata extraDataToSet) internal {
        $storage().extraData.set(extraDataToSet);
    }
}
