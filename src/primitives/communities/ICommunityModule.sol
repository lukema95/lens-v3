// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICommunityModule {
    function onMembershipGranted(address account, bytes calldata data) external;

    function onMembershipRevoked(address account, bytes calldata data) external;

    // TODO: Do we need this? To call after leaving a community and clear some state
    function afterLeaving(bytes calldata data) external;

    // TODO: Community Post System functions here? Or different module on the feed?
}
