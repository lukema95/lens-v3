// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {CreatePostParams, EditPostParams} from "../../../primitives/feed/IFeed.sol";
import {IFeedRule} from "../IFeedRule.sol";
import {RestrictedSignersRule, EIP712Signature} from "../../base/RestrictedSignersRule.sol";
import {RuleConfiguration} from "../../../types/Types.sol";

contract RestrictedSignersFeedRule is RestrictedSignersRule, IFeedRule {
    function configure(bytes calldata data) external override {
        _configure(data);
    }

    function processCreatePost(
        uint256 postId,
        uint256 localSequentialId,
        CreatePostParams calldata postParams,
        bytes calldata data
    ) external override {
        _validateRestrictedSignerMessage({
            functionSelector: IFeedRule.processCreatePost.selector,
            abiEncodedFunctionParams: abi.encode(postId, localSequentialId, postParams),
            signature: abi.decode(data, (EIP712Signature))
        });
    }

    function processEditPost(
        uint256 postId,
        uint256 localSequentialId,
        EditPostParams calldata editPostParams,
        bytes calldata data
    ) external override {
        _validateRestrictedSignerMessage({
            functionSelector: IFeedRule.processEditPost.selector,
            abiEncodedFunctionParams: abi.encode(postId, localSequentialId, editPostParams),
            signature: abi.decode(data, (EIP712Signature))
        });
    }

    function processDeletePost(uint256 postId, uint256 localSequentialId, bytes calldata data) external override {
        _validateRestrictedSignerMessage({
            functionSelector: IFeedRule.processDeletePost.selector,
            abiEncodedFunctionParams: abi.encode(postId, localSequentialId),
            signature: abi.decode(data, (EIP712Signature))
        });
    }

    function processPostRulesChanged(
        uint256 postId,
        uint256 localSequentialId,
        RuleConfiguration[] calldata newPostRules,
        bytes calldata data
    ) external override {
        _validateRestrictedSignerMessage({
            functionSelector: IFeedRule.processPostRulesChanged.selector,
            abiEncodedFunctionParams: abi.encode(postId, localSequentialId, newPostRules),
            signature: abi.decode(data, (EIP712Signature))
        });
    }
}
