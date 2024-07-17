// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IRules} from './IRules.sol';

interface IUsernameRules is IRules {
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
