// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICommunityRules {
    function initialize(bytes calldata data) external;

    function processJoining(address originalMsgSender, address account, bytes calldata data) external;

    function processRemoval(address originalMsgSender, address account, bytes calldata data) external;

    function processLeaving(address originalMsgSender, address account, bytes calldata data) external;
}
