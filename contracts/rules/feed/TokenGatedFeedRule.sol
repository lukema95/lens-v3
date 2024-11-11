// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {CreatePostParams, EditPostParams} from "./../../core/interfaces/IFeed.sol";
import {IFeedRule} from "./../../core/interfaces/IFeedRule.sol";
import {RuleConfiguration} from "./../../core/types/Types.sol";
import {TokenGatedRule} from "./../base/TokenGatedRule.sol";

contract TokenGatedFeedRule is TokenGatedRule, IFeedRule {
    mapping(address => TokenGateConfiguration) internal _configuration;

    function configure(bytes calldata data) external override {
        TokenGateConfiguration memory configuration = abi.decode(data, (TokenGateConfiguration));
        _validateTokenGateConfiguration(configuration);
        _configuration[msg.sender] = configuration;
    }

    function processCreatePost(uint256, /* postId */ CreatePostParams calldata postParams, bytes calldata /* data */ )
        external
        view
        override
        returns (bool)
    {
        _validateTokenBalance(_configuration[msg.sender], postParams.author);
        return true;
    }

    function processEditPost(
        uint256, /* postId */
        EditPostParams calldata, /* editPostParams */
        bytes calldata /* data */
    ) external pure override returns (bool) {
        return false;
    }

    function processPostRulesChanged(
        uint256, /* postId */
        RuleConfiguration[] calldata, /* newPostRules */
        bytes calldata /* data */
    ) external pure override returns (bool) {
        return false;
    }
}
