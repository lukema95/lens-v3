// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUsernameRule {
    function configure(bytes calldata data) external;

    function processCreation(address account, string memory username, bytes calldata data) external;

    function processRemoval(address account, string memory username, bytes calldata data) external;

    function processLinking(address account, string memory username, bytes calldata data) external;

    function processUnlinking(address account, string memory username, bytes calldata data) external;
}
