// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FollowGraphCore {
    mapping(address => mapping(address => bool)) internal _isFollowing;

    function follow(address followerAccount, address targetAccount) external {
        _isFollowing[followerAccount][targetAccount] = true;
    }

    function unfollow(address followerAccount, address targetAccount) external {
        _isFollowing[followerAccount][targetAccount] = false;
    }

    function isFollowing(address followerAccount, address targetAccount) external view returns (bool) {
        return _isFollowing[followerAccount][targetAccount];
    }
}

contract FollowGraph_Paid {
    FollowGraphCore _followGraphCore;

    function follow(address targetAccount) external {
        FollowGraphCore(_followGraphCore).delegateCall(follow(msg.sender, targetAccount));
    }

    function unfollow(address targetAccount) external {
        FollowGraphCore(_followGraphCore).delegateCall(unfollow(msg.sender, targetAccount));
    }

    function isFollowing(address targetAccount) external view returns (bool) {
        return FollowGraphCore(_followGraphCore).delegateCall(isFollowing(msg.sender, targetAccount));
    }
}

/**
 * I think we should define the interface of each primitive to take rules into account (e.g. bytes calldata ruleData, etc.).
 * Then it's just happens that our implementation of the primitive has this underlying "core primitive" library contract
 * which do not have rules into account, but instead we put them on top in the "wrapper primitive" contract.
 */
