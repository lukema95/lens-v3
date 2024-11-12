// SPDX-License-Identifier: UNLICENSED
// Copyright (C) 2024 Lens Labs. All Rights Reserved.
pragma solidity ^0.8.0;

interface IGroupRule {
    function configure(bytes calldata data) external;

    function processJoining(address account, uint256 membershipId, bytes calldata data) external returns (bool);

    function processRemoval(address account, uint256 membershipId, bytes calldata data) external returns (bool);
}
