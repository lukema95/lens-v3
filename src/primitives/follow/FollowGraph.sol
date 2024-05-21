// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

struct Follow {
    uint256 id;
    uint256 timestamp;
}

contract FollowGraph {
    // TODO: This also has the opinion of linking addresses(accounts). A more generic Graph primitive could link bytes,
    // where abi.encode(address) would be a particular case. And accounts can be linked to other entities, or whatever.
    address _admin;
    IGraphModule _graphModule;
    mapping(address account => IFollowModule followModule) _followModules;
    mapping(address account => uint256) _followersCount;
    // TODO: The `_follows` mapping is assuming one follow per account. If we add one extra key to the mapping, that is
    // a uint, then you can have multiple follows per account (also can be done by using an array of Follows, which is
    // basically the same as seeing the extra key as the Follow array index).
    // This means later the IFollowGraph::processFollow can check for amount of follows done, and then restrict
    // quantity of follows per account, being [0, 1] follows per account just a special case.
    mapping(address followerAccount => mapping(address followedAccount => Follow)) _follows;
    mapping(address followedAccount => mapping(uint256 followId => address followerAccount)) _followers;

    function setGraphModule(
        IGraphModule graphModule,
        bytes calldata initializationData
    ) external {
        if (_admin != msg.sender) {
            revert();
        }
        _graphModule = graphModule;
        graphModule.initialize(initializationData);
    }

    function setFollowModule(
        IFollowModule followModule,
        bytes calldata initializationData,
        bytes calldata graphModuleData
    ) external {
        _followModules[msg.sender] = followModule;
        // We call the follow module first, in case the graph module requires the follow module to be initialized first.
        followModule.initialize(initializationData);
        _graphModule.processFollowModuleChange(
            msg.sender,
            followModule,
            initializationData,
            graphModuleData
        );
    }

    // TODO: What do we return?
    function follow(
        address accountToFollow,
        bytes calldata graphModuleData,
        bytes calldata followModuleData
    ) external {
        uint256 followId = ++_followersCount[accountToFollow];
        _follows[msg.sender][accountToFollow] = Follow({
            id: followId,
            timestamp: block.timestamp
        });
        _followers[accountToFollow][followId] = msg.sender;
        _graphModule.processFollow(accountToFollow, graphModuleData);
        _followModules[accountToFollow].processFollow(
            msg.sender,
            followModuleData
        );
    }

    function unfollow(
        address accountToUnfollow,
        bytes calldata graphModuleData
    ) external {
        _graphModule.processUnfollow(accountToUnfollow, graphModuleData);
    }
}

interface IGraphModule {
    function initialize(bytes calldata data) external;

    function processFollow(
        address accountToFollow,
        bytes calldata data
    ) external;

    // TODO: Should this exist? Maybe not, so it cannot prevent the unfollow...
    // Maybe the function should exist but not being called by `unfollow` but by the user in a separate tx later.
    // We could even do wrappers for this, given that all the accounts are smart contracts
    function processUnfollow(
        address accountToUnfollow,
        bytes calldata data
    ) external;

    // TODO: Should the block be global? Or at least have a global registry to signal it too...
    function processBlock(address account, bytes calldata data) external;

    function processUnblock(address account, bytes calldata data) external;

    function processFollowModuleChange(
        address account,
        IFollowModule followModule,
        bytes calldata followModuleInitData,
        bytes calldata data
    ) external;
}

interface IFollowModule {
    /**
     * Initializes the FollowModule with the data required to operate.
     * @param data Data that the FollowModule might require to initialize.
     */
    function initialize(bytes calldata data) external;

    /**
     * Predicate to be evaluated upon each follow using the logic set by `accountToFollow`. Finishes execution
     * successfully if the predicate evalues to "true", reverts if the predicate evaluates to "false".
     * @param accountToFollow The account to be followed.
     * @param data Data that the FollowModule might require to evalute the follow.
     */
    function processFollow(
        address accountToFollow,
        bytes calldata data
    ) external;
}
