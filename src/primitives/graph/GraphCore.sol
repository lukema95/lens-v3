// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// TODO: We can do storage packing if we want to...
struct Follow {
    uint256 id;
    uint256 timestamp;
}

//TODO: Can be a Library instead of a Contract. It requires proper storage management.
contract GraphCore {
    string internal _metadataURI;
    mapping(address account => uint256 lastFollowIdAssigned) internal _lastFollowIdAssigned;
    mapping(address followerAccount => mapping(address followedAccount => Follow follow)) internal _follows;
    mapping(address followedAccount => mapping(uint256 followId => address followerAccount)) internal _followers;
    mapping(address followedAccount => uint256 followersCount) internal _followersCount;

    // event Graph_Followed(address followerAccount, address accountToFollow, uint256 followId);
    // event Graph_Unfollowed(address followerAccount, address accountToUnfollow, uint256 followId);

    // External functions

    function follow(address followerAccount, address accountToFollow, uint256 followId) external returns (uint256) {
        return _follow(followerAccount, accountToFollow, followId);
    }

    function unfollow(address followerAccount, address accountToUnfollow) external returns (uint256) {
        return _unfollow(followerAccount, accountToUnfollow);
    }

    // Internal functions (Only makes sense to have this if we do this a library)

    function _follow(address followerAccount, address accountToFollow, uint256 followId) internal returns (uint256) {
        if (followId == 0) {
            followId = ++_lastFollowIdAssigned[accountToFollow];
        } else if (
            followId > _lastFollowIdAssigned[accountToFollow] || _followers[accountToFollow][followId] != address(0)
        ) {
            revert();
        }
        _follows[followerAccount][accountToFollow] = Follow({id: followId, timestamp: block.timestamp});
        _followers[accountToFollow][followId] = followerAccount;
        _followersCount[accountToFollow]++;
        // emit Graph_Followed(followerAccount, accountToFollow, followId);
        return followId;
    }

    function _unfollow(address followerAccount, address accountToUnfollow) internal returns (uint256) {
        uint256 followId = _follows[followerAccount][accountToUnfollow].id;
        if (followId == 0) {
            // Not following!
            revert();
        }
        _followersCount[accountToUnfollow]--;
        // emit Graph_Unfollowed(followerAccount, accountToUnfollow, followId);
        delete _followers[accountToUnfollow][followId];
        delete _follows[followerAccount][accountToUnfollow];
        return followId;
    }
}
