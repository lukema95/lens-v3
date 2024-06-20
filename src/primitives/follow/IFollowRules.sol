// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IFollowRules {
    /**
     * Initializes the FollowRules with the data required to operate.
     * @param data Data that the FollowRules might require to initialize.
     */
    function initialize(bytes calldata data) external;

    /**
     * Predicate to be evaluated upon each follow using the logic set by `accountToFollow`. Finishes execution
     * successfully if the predicate evalues to "true", reverts if the predicate evaluates to "false".
     * @param accountToFollow The account to be followed.
     * @param data Data that the FollowRules might require to evalute the follow.
     */
    function processFollow(address msgSender, address accountToFollow, uint256 followId, bytes calldata data) external;

    // We don't have processUnfollow() function because it can prevent from unfollowing or have other weird consequences

    // TODO: We can add a standard function here like `processAfterUnfollow` or some more clear name
    // That should be called by the user after the unfollow, to clean state or withdraw stuff.
    // The idea of adding it in the interface is to standarize it, so everyone can call it without making it bespoke to
    // each module.
}
