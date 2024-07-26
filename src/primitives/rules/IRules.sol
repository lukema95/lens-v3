// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRules {
    event Lens_RuleConfigured(bytes data);

    function configure(bytes calldata data) external;
}
