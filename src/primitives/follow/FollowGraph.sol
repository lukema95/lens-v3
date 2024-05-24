// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

struct Follow {
    uint256 id;
    uint256 timestamp;
}

struct Permissions {
    bool canFollow;
    bool canUnfollow;
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

    mapping(address => Permissions) _permissions;

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
        _follow(accountToFollow, followId, graphModuleData, followModuleData);
    }

    function followWithId(
        address accountToFollow,
        uint256 followId,
        bytes calldata graphModuleData,
        bytes calldata followModuleData
    ) external {
        if (_followers[accountToFollow][followId] != address(0)) {
            revert();
        }
        _follow(accountToFollow, followId, graphModuleData, followModuleData);
    }

    function _follow(
        address accountToFollow,
        uint256 followId,
        bytes calldata graphModuleData,
        bytes calldata followModuleData
    ) internal {
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
        address followerAccount,
        address accountToUnfollow,
        bytes calldata graphModuleData
    ) external {
        if (
            msg.sender != followerAccount &&
            !_permissions[msg.sender].canUnfollow
        ) {
            revert();
        }
        _unfollow(followerAccount, accountToUnfollow, graphModuleData);
    }

    // Helper to simplify things (without providing the followerAccount, but assume msg.sender is the follower)
    function unfollow(
        address accountToUnfollow,
        bytes calldata graphModuleData
    ) external {
        _unfollow(msg.sender, accountToUnfollow, graphModuleData);
    }

    function _unfollow(
        address followerAccount,
        address accountToUnfollow,
        bytes calldata graphModuleData
    ) internal {
        _graphModule.processUnfollow(accountToUnfollow, graphModuleData);
        delete _follows[followerAccount][accountToUnfollow];
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

// Minter

/*
    Authentication flow for all the functions:

    ERC721 functions:
    - transferFrom() - ownerOf(nftID) can do it (or approved)
    - approve, blablabla - ownerOf(nftID) can do it

    NFT mint/burn functions:
    - mint()
      * If you want to mint() an NFT - you must be the one following
    - burn()
      * to burn you need to set the minter as a DE in your account - so it can also do unfollow() on burn
        + That can be done using MultiCall (setDE, burn, unsetDE)
      * Alternatively, you can burn if no follower is set.

    FollowGraph functions:
    - follow() - the one who holds the NFT must be able to perform follow (and unfollow the previous guy)
      * And to perform follow - the one who originally follows should have the DE set and the holder also needs to have the DE set
    - unfollow()
    - block()
    - unblock()

//////////

    1) You have Follower #1 of Stani and you follow him
    2) You sell the NFT to Josh
    3) Josh can:
       - Follow stani using this NFT keeping the Follower #1 id in the FollowGraph

    

*/
