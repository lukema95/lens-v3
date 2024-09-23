// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {RuleExecutionData} from "./../../types/Types.sol";

interface IUsernameRule {
    function configure(bytes calldata data) external;

    function processRegistering(address account, string memory username, RuleExecutionData calldata data) external;

    function processUnregistering(address account, string memory username, RuleExecutionData calldata data) external;
}
