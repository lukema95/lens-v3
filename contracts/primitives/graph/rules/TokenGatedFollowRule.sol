// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IFollowRule} from "../IFollowRule.sol";
import {TokenGatedRule} from "../../base/TokenGatedRule.sol";

contract TokenGatedFollowRule is TokenGatedRule, IFollowRule {
    mapping(address graph => mapping(address account => TokenGateConfiguration configuration)) internal _configuration;

    function configure(address account, bytes calldata data) external {
        TokenGateConfiguration memory configuration = abi.decode(data, (TokenGateConfiguration));
        _validateTokenGateConfiguration(configuration);
        _configuration[msg.sender][account] = configuration;
    }

    function processFollow(
        address followerAccount,
        address accountToFollow,
        uint256, /* followId */
        bytes calldata /* data */
    ) external view returns (bool) {
        _validateTokenBalance(_configuration[msg.sender][accountToFollow], followerAccount);
        return true;
    }
}
