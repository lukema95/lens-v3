// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IFollowModule} from './IFollowModule.sol';
import {IGraphExtension} from './IGraphExtension.sol';

interface IFollowGraph {
    struct Follow {
        uint256 id;
        uint256 timestamp;
    }

    struct Permissions {
        bool canFollow;
        bool canUnfollow;
    }

    function setGraphExtension(IGraphExtension graphExtension, bytes calldata initializationData) external;

    function setPermissions(address account, Permissions calldata permissions) external;

    function setFollowModule(
        IFollowModule followModule,
        bytes calldata initializationData,
        bytes calldata graphExtensionData
    ) external;

    function follow(
        address followerAccount,
        address accountToFollow,
        uint256 followId,
        bytes calldata graphExtensionData,
        bytes calldata followModuleData
    ) external;

    function unfollow(address followerAccount, address accountToUnfollow, bytes calldata graphExtensionData) external;

    function follow(
        address accountToFollow,
        bytes calldata graphExtensionData,
        bytes calldata followModuleData
    ) external;

    function unfollow(address accountToUnfollow, bytes calldata graphExtensionData) external;

    function isFollowing(address followerAccount, address targetAccount) external view returns (bool);

    function getFollowerById(address account, uint256 followId) external view returns (address);

    function getFollow(address followerAccount, address followedAccount) external view returns (Follow memory);

    function getFollowModule(address account) external view returns (IFollowModule);

    function getPermissions(address account) external view returns (Permissions memory);

    function getFollowersCount(address account) external view returns (uint256);

    function getAdmin() external view returns (address);

    function getGraphExtension() external view returns (IGraphExtension);
}
