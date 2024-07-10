// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUsernameRules {
    function initialize(bytes calldata data) external;

    function processRegistering(
        address originalMsgSender,
        address account,
        string memory username,
        bytes calldata data
    ) external;

    function processUnregistering(
        address originalMsgSender,
        address account,
        string memory username,
        bytes calldata data
    ) external;
}
