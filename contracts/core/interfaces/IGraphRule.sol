// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {RuleConfiguration} from "./../types/Types.sol";

interface IGraphRule {
    function configure(bytes calldata data) external;

    function processFollow(address followerAccount, address accountToFollow, uint256 followId, bytes calldata data)
        external
        returns (bool);

    function processFollowRulesChange(address account, RuleConfiguration[] calldata followRules, bytes calldata data)
        external
        returns (bool);
}
