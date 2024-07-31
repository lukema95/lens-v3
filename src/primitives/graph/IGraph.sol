// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IFollowRules} from './IFollowRules.sol';
import {IGraphRules} from './IGraphRules.sol';

interface IGraph {
    struct Follow {
        uint256 id;
        uint256 timestamp;
    }

    event Lens_Graph_RulesSet(address graphRules);

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

    function setGraphRules(IGraphRules graphRules, bytes calldata initializationData) external;

    function setFollowRules(
        IFollowRules followRules,
        bytes calldata followRulesInitData,
        bytes calldata graphRulesData
    ) external;

    function follow(
        address followerAccount,
        address targetAccount,
        uint256 followId,
        bytes calldata graphRulesData,
        bytes calldata followRulesData
    ) external;

    function unfollow(address followerAccount, address targetAccount, bytes calldata graphRulesData) external;

    // Getters

    function isFollowing(address followerAccount, address targetAccount) external view returns (bool);

    function getFollowerById(address account, uint256 followId) external view returns (address);

    function getFollow(address followerAccount, address followedAccount) external view returns (Follow memory);

    function getFollowersCount(address account) external view returns (uint256);

    function getFollowRules(address account) external view returns (IFollowRules);

    function getGraphRules() external view returns (IGraphRules);
}
