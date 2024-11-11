// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFollowRule {
    function configure(address account, bytes calldata data) external;

    function processFollow(address followerAccount, address accountToFollow, uint256 followId, bytes calldata data)
        external
        returns (bool);
}
