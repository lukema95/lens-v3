// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IGraphRule} from "../IGraphRule.sol";
import {RuleConfiguration} from "../../../types/Types.sol";
import {TokenGatedRule} from "../../base/TokenGatedRule.sol";

contract TokenGatedGraphRule is TokenGatedRule, IGraphRule {
    mapping(address graph => TokenGateConfiguration configuration) internal _configuration;

    function configure(bytes calldata data) external override {
        TokenGateConfiguration memory configuration = abi.decode(data, (TokenGateConfiguration));
        _validateTokenGateConfiguration(configuration);
        _configuration[msg.sender] = configuration;
    }

    function processFollow(
        address followerAccount,
        address accountToFollow,
        uint256, /* followId */
        bytes calldata /* data*/
    ) external view returns (bool) {
        TokenGateConfiguration memory configuration = _configuration[msg.sender];
        /**
         * Both ends of the follow connection must comply with the token-gate restriction, then the graph is purely
         * conformed by token holders.
         */
        _validateTokenBalance(configuration, followerAccount);
        _validateTokenBalance(configuration, accountToFollow);
        return true;
    }

    function processUnfollow(
        address, /* unfollowerAccount */
        address, /* accountToUnfollow */
        uint256, /* followId */
        bytes calldata /* data*/
    ) external pure returns (bool) {
        return false;
    }

    function processFollowRulesChange(
        address, /* account*/
        RuleConfiguration[] calldata, /*followRules*/
        bytes calldata /* data*/
    ) external pure returns (bool) {
        return false;
    }
}
