// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IRule} from "./../rules/IRule.sol";

interface IUsernameRule is IRule {
    function processRegistering(address originalMsgSender, address account, string memory username, bytes calldata data)
        external;

    function processUnregistering(
        address originalMsgSender,
        address account,
        string memory username,
        bytes calldata data
    ) external;
}
