// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IFollowGraph} from './IFollowGraph.sol';
import {IFollowModule} from './IFollowModule.sol';
import {IGraphExtension} from './IGraphExtension.sol';

struct Follow {
    uint256 id;
    uint256 timestamp;
}

struct Permissions {
    bool canFollow;
    bool canUnfollow;
    // TODO: Why not having `canSetFollowModule`, `canBlock`, `canUnblock`? It seems more flexible and it feels (un)follow
    // have the same level of relevance as the other permissions.
}

// library ExtensionCalls {
//     function processFollowIfPresent(
//         IGraphExtension graphExtension,
//         address originalMsgSender,
//         address followerAcount,
//         address accountToFollow,
//         uint256 followId,
//         bytes calldata data
//     ) internal {
//         if (address(graphExtension) != address(0)) {
//             graphExtension.processFollow(originalMsgSender, followerAcount, accountToFollow, followId, data);
//         }
//     }
// }

contract FollowGraph is IFollowGraph {
    // using ExtensionCalls for IGraphExtension;

    // TODO: This also has the opinion of linking addresses(accounts). A more generic Graph primitive could link bytes,
    // where abi.encode(address) would be a particular case. And accounts can be linked to other entities, or whatever.
    address internal _admin; // TODO: Make the proper Ownable pattern
    IGraphExtension internal _graphExtension;
    mapping(address account => IFollowModule followModule) internal _followModules;
    mapping(address account => uint256) internal _lastFollowIdAssigned;
    // TODO: The `_follows` mapping is assuming one follow per account. If we add one extra key to the mapping, that is
    // a uint, then you can have multiple follows per account (also can be done by using an array of Follows, which is
    // basically the same as seeing the extra key as the Follow array index).
    // This means later the IFollowGraph::processFollow can check for amount of follows done, and then restrict
    // quantity of follows per account, being [0, 1] follows per account just a special case.
    // => If we stay as 'FollowGraph' we should be opinionated in single-follow, but if we go to the generic 'Graph'
    // approach, then allowing the multi-edge/multi-link approach would make more sense.
    mapping(address followerAccount => mapping(address followedAccount => Follow)) internal _follows;
    mapping(address followedAccount => mapping(uint256 followId => address followerAccount)) internal _followers;
    // Global permissions over the graph
    mapping(address account => Permissions permissions) internal _permissions;
    mapping(address followedAccount => uint256 followersCount) internal _followersCount;

    // Admin functions

    // TODO: We can have this to allow discoverability of entryPoint
    // function getEntryPoint() external pure returns (address) {
    //     return address(this);
    // }

    function setGraphExtension(IGraphExtension graphExtension, bytes calldata initializationData) external {
        if (_admin != msg.sender) {
            revert();
        }
        _graphExtension = graphExtension;
        if (address(_graphExtension) != address(0)) {
            graphExtension.initialize(initializationData);
        }
    }

    // Public user functions

    function setPermissions(address account, Permissions calldata permissions) external {
        if (_admin != msg.sender) {
            revert();
        }
        _permissions[account] = permissions;
    }

    function setFollowModule(
        IFollowModule followModule,
        bytes calldata initializationData,
        bytes calldata graphExtensionData
    ) external {
        _followModules[msg.sender] = followModule;
        // We call the follow module first, in case the graph module requires the follow module to be initialized first.
        followModule.initialize(initializationData);
        if (address(_graphExtension) != address(0)) {
            _graphExtension.processFollowModuleChange(msg.sender, followModule, initializationData, graphExtensionData);
        }
    }

    // TODO: What do we return?
    function follow(
        address followerAccount,
        address accountToFollow,
        uint256 followId,
        bytes calldata graphExtensionData,
        bytes calldata followModuleData
    ) public {
        if (msg.sender != followerAccount && !_permissions[msg.sender].canFollow) {
            revert();
        }
        _follow(followerAccount, accountToFollow, followId, graphExtensionData, followModuleData);
    }

    function unfollow(address followerAccount, address accountToUnfollow, bytes calldata graphExtensionData) public {
        if (msg.sender != followerAccount && !_permissions[msg.sender].canUnfollow) {
            revert();
        }
        _unfollow(followerAccount, accountToUnfollow, graphExtensionData);
    }

    // TODO: Think if we need this?
    // Helpers to simplify things (without providing the followerAccount, but assume msg.sender is the follower):
    function follow(
        address accountToFollow,
        bytes calldata graphExtensionData,
        bytes calldata followModuleData
    ) external {
        follow(msg.sender, accountToFollow, 0, graphExtensionData, followModuleData);
    }

    function unfollow(address accountToUnfollow, bytes calldata graphExtensionData) external {
        unfollow(msg.sender, accountToUnfollow, graphExtensionData);
    }

    // Internal functions

    function _follow(
        address followerAccount,
        address accountToFollow,
        uint256 followId,
        bytes calldata graphExtensionData,
        bytes calldata followModuleData
    ) internal {
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
        if (address(_graphExtension) != address(0)) {
            _graphExtension.processFollow(msg.sender, followerAccount, accountToFollow, followId, graphExtensionData);
        }
        if (address(_followModules[accountToFollow]) != address(0)) {
            _followModules[accountToFollow].processFollow(msg.sender, followerAccount, followId, followModuleData);
        }
    }

    function _unfollow(address followerAccount, address accountToUnfollow, bytes calldata graphExtensionData) internal {
        uint256 followId = _follows[followerAccount][accountToUnfollow].id;
        if (followId == 0) {
            // Not following!
            revert();
        }
        if (address(_graphExtension) != address(0)) {
            _graphExtension.processUnfollow(
                msg.sender,
                followerAccount,
                accountToUnfollow,
                followId,
                graphExtensionData
            );
        }
        // We don't have FollowModule.processUnfollow because it can prevent from unfollowing
        _followersCount[accountToUnfollow]--;
        delete _followers[accountToUnfollow][followId];
        delete _follows[followerAccount][accountToUnfollow];
    }

    // Getters

    function isFollowing(address followerAccount, address targetAccount) external view returns (bool) {
        return _follows[followerAccount][targetAccount].id != 0;
    }

    function getFollowerById(address account, uint256 followId) external view returns (address) {
        return _followers[account][followId];
    }

    function getFollow(address followerAccount, address followedAccount) external view returns (Follow memory) {
        return _follows[followerAccount][followedAccount];
    }

    function getFollowModule(address account) external view returns (IFollowModule) {
        return _followModules[account];
    }

    function getPermissions(address account) external view returns (Permissions memory) {
        return _permissions[account];
    }

    function getFollowersCount(address account) external view returns (uint256) {
        return _followersCount[account];
    }

    function getAdmin() external view returns (address) {
        return _admin;
    }

    function getGraphExtension() external view returns (IGraphExtension) {
        return _graphExtension;
    }
}
