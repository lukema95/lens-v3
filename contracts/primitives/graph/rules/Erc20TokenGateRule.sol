// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../../../lib/forge-std/src/interfaces/IERC20.sol";
import {IGraphRule} from "../IGraphRule.sol";
import {RuleConfiguration} from "../../../types/Types.sol";

contract Erc20TokenGateRule is IGraphRule {
    struct RuleStorage {
        address token;
        uint256 amount;
    }

    RuleStorage internal ruleStorage;

    function configure(bytes calldata data) external override {
        (address token, uint256 amount) = abi.decode(data, (address, uint256));
        _configure(token, amount);
    }

    function processFollow(address followerAccount, address accountToFollow, uint256 followId, bytes calldata data)
        external
        override
    {
        _validateErc20TokenOwnership(ruleStorage.token, ruleStorage.amount, followerAccount);
    }

    function processUnfollow(
        address unfollowerAccount,
        address accountToUnfollow,
        uint256 followId,
        bytes calldata data
    ) external override {
        // nothing to do here
    }

    function processFollowRulesChange(address account, RuleConfiguration[] calldata followRules, bytes calldata data)
        external
        override
    {
        // nothing to do here
    }

    function _configure(address token, uint256 amount) internal {
        if (token == address(0)) {
            revert("Errors.invalidTokenAddress()");
        }
        if (amount == 0) {
            revert("Errors.cannotSetZeroAmount()");
        }

        ruleStorage.token = token;
        ruleStorage.amount = amount;
    }

    function _validateErc20TokenOwnership(address token, uint256 amount, address owner) internal view {
        IERC20 erc20Token = IERC20(token);

        uint256 balance = erc20Token.balanceOf(owner);

        if (balance < amount) {
            revert("Errors.notEnoughTokens()");
        }
    }
}
