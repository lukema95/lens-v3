// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUsernameModule {
    function initialize(bytes calldata data) external;

    function processRegistering(address originalMsgSender, string memory username, bytes calldata data) external;
}
