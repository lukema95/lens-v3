// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// contract FollowPrimitive_UintId {
//     mapping(uint256 => mapping(uint256 => bool)) private _isFollowing;

//     function follow(uint256 followerId, uint256 followingId) external {
//         if (!AnotherContract.hasAuth(followerId,msg.sender)){
//             revert();
//         }
//         _isFollowing[followerId][followingId] = true;
//     }

//     function unfollow(uint256 followerId, uint256 followingId) external {
//         _isFollowing[followerId][followingId] = false;
//     }

//     function isFollowing(
//         uint256 followerId,
//         uint256 followingId
//     ) external view returns (bool) {
//         return _isFollowing[followerId][followingId];
//     }
// }

contract FollowGraphTokenizer is ERC721 {
    FollowPrimitive_AddyId followGraph;

    function tokenize(
        address followedProfileId,
        address followTokenRecipient
    ) external {
        uint256 followId = followGraph.isFollowing(
            msg.sender,
            followedProfileId
        );
        if (followId == 0) {
            revert("Not following");
        }
        // _mint function will handle existance checks (i.e. already tokenized before).
        _mint(followTokenRecipient, followId);
    }
}

contract FollowPrimitive_AddyId {
    mapping(address => uint256) private _lastFollowIdAssigned;
    mapping(address => mapping(address => uint256)) private _isFollowing;

    function follow(address followingId) external {
        _isFollowing[msg.sender][followingId] = ++_lastFollowIdAssigned[
            followingId
        ];
    }

    function unfollow(address followingId) external {
        delete _isFollowing[msg.sender][followingId];
    }

    function isFollowing(
        address followerId,
        address followingId
    ) external view returns (uint256) {
        return _isFollowing[followerId][followingId];
    }
}

// To be honest, I don't see the point of this, against using a DB. Extra cost for nothing. Just blockchain buzzword.
contract FollowPrimitive_NoAccounts {
    address owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    mapping(bytes => mapping(bytes => bool)) private _isFollowing;

    function follow(
        bytes memory follower,
        bytes memory followed
    ) external onlyOwner {
        _isFollowing[follower][followed] = true;
    }

    function unfollow(
        bytes memory follower,
        bytes memory followed
    ) external onlyOwner {
        _isFollowing[follower][followed] = false;
    }

    function isFollowing(
        bytes memory follower,
        bytes memory followed
    ) external view returns (bool) {
        return _isFollowing[follower][followed];
    }
}
