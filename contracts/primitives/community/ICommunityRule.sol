// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IRule} from "./../rules/IRule.sol";

interface ICommunityRule is IRule {
    function processJoining(
        address originalMsgSender,
        address account,
        bytes calldata data
    ) external;

    function processRemoval(
        address originalMsgSender,
        address account,
        bytes calldata data
    ) external;

    function processLeaving(
        address originalMsgSender,
        address account,
        bytes calldata data
    ) external;
}
