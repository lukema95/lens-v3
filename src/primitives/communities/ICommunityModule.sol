// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICommunityModule {
    function initialize(bytes calldata data) external;

    function onMembershipGranted(address originalMsgSender, address account, bytes calldata data) external;

    function onMembershipRevoked(address originalMsgSender, address account, bytes calldata data) external;

    // TODO: Do we need this? To call after leaving a community and clear some state
    function afterLeaving(bytes calldata data) external;
}
