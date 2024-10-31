// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IPostAction} from "./IPostAction.sol";

/**
 *  @notice A struct containing the necessary data to add a fee to the collect action.
 *
 *  @param collector The address of the fee collector.
 *  @param fee The fee associated with this collect. A percentage from 0 to 10000.
 */
struct CollectFee {
    address collector;
    uint16 fee;
}

/**
 * @notice A struct containing the necessary data to initialize this Base Collect Module.
 *
 * @param amount The collecting cost associated with this post. 0 for free collect.
 * @param collectLimit The maximum number of collects for this publication. 0 for no limit.
 * @param currency The currency associated with this publication.
 * @param referralFee The referral fee associated with this publication.
 * @param followerOnly True if only followers of publisher may collect the post.
 * @param endTimestamp The end timestamp after which collecting is impossible. 0 for no expiry.
 * @param recipient Recipient of collect fees.
 * @param fees An array of fees to charge for collects.
 */
struct BaseCollectActionConfigureData {
    uint160 amount;
    uint96 collectLimit;
    address currency;
    uint16 referralFee;
    bool followerOnly;
    uint72 endTimestamp;
    address recipient;
    CollectFee[] fees;
}

/**
 * @notice A struct containing the necessary data to execute collect actions on a publication.
 *
 * @param amount The collecting cost associated with this publication. 0 for free collect.
 * @param collectLimit The maximum number of collects for this publication. 0 for no limit.
 * @param currency The currency associated with this publication.
 * @param currentCollects The current number of collects for this publication.
 * @param referralFee The referral fee associated with this publication.
 * @param followerOnly True if only followers of publisher may collect the post.
 * @param endTimestamp The end timestamp after which collecting is impossible. 0 for no expiry.
 * @param recipient Recipient of collect fees.
 * @param fees An array of fees to charge for collects.
 */
struct BaseCollectActionExecuteData {
    uint160 amount;
    uint96 collectLimit;
    address currency;
    uint96 currentCollects;
    address recipient;
    uint16 referralFee;
    bool followerOnly;
    uint72 endTimestamp;
    CollectFee[] fees;
}

interface IBaseCollectAction is IPostAction {
    function getBasePublicationCollectData(address feed, uint256 postId)
        external
        view
        returns (BaseCollectActionExecuteData memory);
}
