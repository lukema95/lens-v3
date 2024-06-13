// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFeedRules {
    function initialize(bytes calldata data) external;

    // TODO: Author or Authors?

    function onPost(address originalMsgSender, uint256 postId, Post memory post, bytes calldata data) external;

    function onEdit(
        address originalMsgSender,
        uint256 postId,
        Post memory updatedPostData,
        bytes calldata data
    ) external;

    // TODO: 👀
    function onDelete(address originalMsgSender, uint256 postId, bytes calldata data) external;
}

/**
 * //TODO:
 * Make a type resolver that can be put into the events ?
 *
 * We dont validate input, that should be done in the Post modules/extensions, same place where they could ask the author
 * to belong to a certain community or any other rules. So they check that quoted or parent posts are existent.
 * Or any other logic like (we only allow things if have contentURI set).
 *
 * Just a post function or we allow multiple? This maybe can be also done on top as extension, but the core underlying
 * primitive just has a post function, and on top you can have comment, quote, whatever type you wish.
 * Even the type can be emitted by this extension, and maybe the core primitive does not care about types are all...
 */

struct Post {
    address author; // TODO: Array of authors?
    string contentURI; // You might want to store content on IPFS
    string metadataURI; // But metadata on a S3 server
    uint256[] quotedPostIds;
    uint256[] parentPostIds;
    bytes[] extraData; // or extra authors and other stuff can be stored here
}

struct Permissions {
    bool canPost;
    bool canEdit;
    bool canDelete;
}

contract Feed {
    address internal _admin; // TODO: Make the proper Ownable pattern
    mapping(uint256 postId => Post post) internal _posts;
    uint256 internal _lastPostId;
    IFeedRules _feedRules;
    mapping(address account => Permissions permissions) internal _permissions;

    function setFeedRules(IFeedRules feedRules, bytes calldata initializationData) external {
        require(msg.sender == _admin, 'Not the admin');
        _feedRules = feedRules;
        if (address(feedRules) != address(0)) {
            feedRules.initialize(initializationData);
        }
    }

    function setPermissions(address account, Permissions calldata permissions) external {
        require(msg.sender == _admin, 'Not the admin');
        _permissions[account] = permissions;
    }

    // Two params: One is for "hooks", the other is to store associated with the post.
    // For hooks => data
    // To store => attributes
    function post(Post calldata postData, bytes calldata data) external returns (uint256) {
        require(
            msg.sender == postData.author || _permissions[msg.sender].canPost,
            'Not the author nor has permissions'
        );
        _lastPostId++;
        _posts[_lastPostId] = postData;
        _feedRules.onPost(msg.sender, _lastPostId, postData, data);
        _postHook(msg.sender, _lastPostId, postData, data);
        return _lastPostId;
    }

    function editPost(uint256 postId, Post calldata updatedPostData, bytes calldata data) external {
        require(
            msg.sender == _posts[postId].author || _permissions[msg.sender].canEdit,
            'Not the author nor has permissions'
        );
        require(postId <= _lastPostId, 'Post does not exist');
        _feedRules.onEdit(msg.sender, postId, updatedPostData, data);
        _posts[postId] = updatedPostData; // TODO: CEI pattern... hmm...
    }

    function deletePost(uint256 postId, bytes calldata data) external {
        require(
            msg.sender == _posts[postId].author || _permissions[msg.sender].canDelete,
            'Not the author nor has permissions'
        );
        _feedRules.onDelete(msg.sender, postId, data);
        delete _posts[postId];
    }
}
