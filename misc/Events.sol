// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct Post {
    address author; // TODO: Array of authors?
    string contentURI; // You might want to store content on IPFS
    string metadataURI; // But metadata on a S3 server
    uint256[] quotedPostIds;
    uint256[] parentPostIds;
    bytes[] extraData; // TODO: This probably should be replaced with some custom named value shit
}

contract Events {
    event Lens_Community_MemberJoined(address indexed account, uint256 indexed memberId, bytes data);
    event Lens_Community_MemberLeft(address indexed account, uint256 indexed memberId);
    event Lens_Community_MemberRemoved(address indexed account, uint256 indexed memberId, bytes data);

    event Lens_Graph_Followed(
        address indexed followerAccount,
        address indexed accountToFollow,
        uint256 indexed followId,
        bytes graphRulesData,
        bytes followRulesData
    );
    event Lens_Graph_Unfollowed(
        address indexed followerAccount,
        address indexed accountToUnfollow,
        uint256 indexed followId,
        bytes graphRulesData
    );

    event Lens_Username_Unregistered(string username, address indexed previousAccount, bytes data);
    event Lens_Username_Registered(string username, address indexed account, bytes data);

    event Lens_Feed_PostCreated(address indexed author, uint256 indexed postId, Post postData);
    event Lens_Feed_PostEdited(address indexed author, uint256 indexed postId, Post updatedPostData, bytes data);
    event Lens_Feed_PostDeleted(address indexed author, uint256 indexed postId, bytes data);
}
