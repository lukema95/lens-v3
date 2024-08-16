// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IFollowRule} from './IFollowRule.sol';

import {IRule} from 'src/primitives/rules/IRule.sol';

interface IGraphRule is IRule {
    function processFollow(
        address originalMsgSender,
        address followerAcount,
        address accountToFollow,
        uint256 followId,
        bytes calldata data
    ) external;

    // TODO: Should this exist? Maybe not, so it cannot prevent the unfollow...
    // Maybe the function should exist but not being called by `unfollow` but by the user in a separate tx later.
    // We could even do wrappers for this, given that all the accounts are smart contracts
    function processUnfollow(
        address originalMsgSender,
        address followerAccount,
        address accountToUnfollow,
        uint256 followId,
        bytes calldata data
    ) external;

    // TODO: Should the block be global? Or at least have a global registry to signal it too...
    function processBlock(address account, bytes calldata data) external;

    function processUnblock(address account, bytes calldata data) external;

    function processFollowRulesChange(address account, IFollowRule followRules, bytes calldata data) external;
}
