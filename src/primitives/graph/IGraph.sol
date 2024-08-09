// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IFollowRules} from './IFollowRules.sol';
import {IGraphRules} from './IGraphRules.sol';

struct Follow {
    uint256 id;
    uint256 timestamp;
}

interface IGraph {
    event Lens_Graph_RulesSet(address graphRules);

    event Lens_Graph_FollowRulesSet(address account, address followRules, bytes graphRulesData);

    event Lens_Graph_Followed(
        address followerAccount,
        address accountToFollow,
        uint256 followId,
        bytes graphRulesData,
        bytes followRulesData
    );

    event Lens_Graph_Unfollowed(
        address followerAccount,
        address accountToUnfollow,
        uint256 followId,
        bytes graphRulesData
    );

    function setGraphRules(IGraphRules graphRules) external;

    function setFollowRules(address account, IFollowRules followRules, bytes calldata graphRulesData) external;

    function follow(
        address followerAccount,
        address targetAccount,
        uint256 followId,
        bytes calldata graphRulesData,
        bytes calldata followRulesData
    ) external returns (uint256);

    function unfollow(
        address followerAccount,
        address targetAccount,
        bytes calldata graphRulesData
    ) external returns (uint256);

    // Getters

    function isFollowing(address followerAccount, address targetAccount) external view returns (bool);

    function getFollowerById(address account, uint256 followId) external view returns (address);

    function getFollow(address followerAccount, address followedAccount) external view returns (Follow memory);

    function getFollowersCount(address account) external view returns (uint256);

    function getFollowRules(address account) external view returns (IFollowRules);

    function getGraphRules() external view returns (IGraphRules);
}
