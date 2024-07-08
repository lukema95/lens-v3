// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICommunityRules {
    function initialize(bytes calldata data) external;

    function processJoining(address originalMsgSender, address account, bytes calldata data) external;

    function processRemoval(address originalMsgSender, address account, bytes calldata data) external;

    function processLeave(address originalMsgSender, address account, bytes calldata data) external;

    // TODO: Do we need this? To call after leaving a community and clear some state
    function afterLeaving(bytes calldata data) external;
}
