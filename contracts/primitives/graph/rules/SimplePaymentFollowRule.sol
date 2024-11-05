// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IFollowRule} from "../IFollowRule.sol";
import {SimplePaymentRule} from "../../base/SimplePaymentRule.sol";

contract SimplePaymentFollowRule is SimplePaymentRule, IFollowRule {
    mapping(address graph => mapping(address account => PaymentConfiguration configuration)) internal _configuration;

    function configure(address account, bytes calldata data) external {
        PaymentConfiguration memory configuration = abi.decode(data, (PaymentConfiguration));
        _validatePaymentConfiguration(configuration);
        _configuration[msg.sender][account] = configuration;
    }

    function processFollow(
        address followerAccount,
        address accountToFollow,
        uint256, /* followId */
        bytes calldata data
    ) external view returns (bool) {
        _processPayment(
            _configuration[msg.sender][accountToFollow], abi.decode(data, (PaymentConfiguration)), followerAccount
        );
        return true;
    }
}
