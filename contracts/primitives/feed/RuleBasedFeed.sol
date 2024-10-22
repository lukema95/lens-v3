// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IPostRule} from "./IPostRule.sol";
import {IFeedRule} from "./IFeedRule.sol";
import {FeedCore as Core} from "./FeedCore.sol";
import {RulesStorage, RulesLib} from "./../base/RulesLib.sol";
import {RuleConfiguration, RuleExecutionData} from "./../../types/Types.sol";
import {EditPostParams, CreatePostParams, CreateRepostParams} from "./IFeed.sol";

contract RuleBasedFeed {
    using RulesLib for RulesStorage;

    struct RuleBasedStorage {
        RulesStorage feedRulesStorage;
        mapping(uint256 => RulesStorage) postRulesStorage;
    }

    // keccak256('lens.rule.based.feed.storage')
    bytes32 constant RULE_BASED_FEED_STORAGE_SLOT = 0x02d31ef96f666bf684ab1c8a89d21f38a88719152ba49251cdaacb4c11cdae39;

    function $ruleBasedStorage() private pure returns (RuleBasedStorage storage _storage) {
        assembly {
            _storage.slot := RULE_BASED_FEED_STORAGE_SLOT
        }
    }

    function $feedRulesStorage() private view returns (RulesStorage storage _storage) {
        return $ruleBasedStorage().feedRulesStorage;
    }

    function $postRulesStorage(uint256 postId) private view returns (RulesStorage storage _storage) {
        return $ruleBasedStorage().postRulesStorage[postId];
    }

    // Internal

    function _addFeedRule(RuleConfiguration calldata rule) internal {
        $feedRulesStorage().addRule(rule, abi.encodeCall(IFeedRule.configure, (rule.configData)));
    }

    function _updateFeedRule(RuleConfiguration calldata rule) internal {
        $feedRulesStorage().updateRule(rule, abi.encodeCall(IFeedRule.configure, (rule.configData)));
    }

    function _removeFeedRule(address rule) internal {
        $feedRulesStorage().removeRule(rule);
    }

    function _addPostRule(uint256 postId, RuleConfiguration calldata rule) internal {
        $postRulesStorage(postId).addRule(rule, abi.encodeCall(IPostRule.configure, (postId, rule.configData)));
    }

    function _updatePostRule(uint256 postId, RuleConfiguration calldata rule) internal {
        $postRulesStorage(postId).updateRule(rule, abi.encodeCall(IPostRule.configure, (postId, rule.configData)));
    }

    function _removePostRule(uint256 postId, address rule) internal {
        $postRulesStorage(postId).removeRule(rule);
    }

    function _processQuotedPostRules(
        uint256 quotedPostId,
        uint256 postId,
        RuleExecutionData calldata quotedPostRulesData
    ) internal {
        uint256 rootPostId = Core.$storage().posts[quotedPostId].rootPostId;
        RulesStorage storage rulesToProcess = $postRulesStorage(rootPostId);

        // Check required rules (AND-combined rules)
        for (uint256 i = 0; i < rulesToProcess.requiredRules.length; i++) {
            (bool callNotReverted,) = rulesToProcess.requiredRules[i].call(
                abi.encodeCall(
                    IPostRule.processQuote, (quotedPostId, postId, quotedPostRulesData.dataForRequiredRules[i])
                )
            );
            require(callNotReverted, "Some required rule failed");
        }
        // Check any-of rules (OR-combined rules)
        if (rulesToProcess.anyOfRules.length == 0) {
            return; // If there are no OR-combined rules, we can return
        }
        for (uint256 i = 0; i < rulesToProcess.anyOfRules.length; i++) {
            (bool callNotReverted, bytes memory returnData) = rulesToProcess.anyOfRules[i].call(
                abi.encodeCall(IPostRule.processQuote, (quotedPostId, postId, quotedPostRulesData.dataForAnyOfRules[i]))
            );
            if (callNotReverted && abi.decode(returnData, (bool))) {
                // Note: abi.decode would fail if call reverted, so don't put this out of the brackets!
                return; // If any of the OR-combined rules passed, it means they succeed and we can return
            }
        }
        revert("All of the OR rules failed");
    }

    function _processParentPostRules(
        uint256 parentPostId,
        uint256 postId,
        RuleExecutionData calldata parentPostRulesData
    ) internal {
        uint256 rootPostId = Core.$storage().posts[parentPostId].rootPostId;
        RulesStorage storage rulesToProcess = $postRulesStorage(rootPostId);

        // Check required rules (AND-combined rules)
        for (uint256 i = 0; i < rulesToProcess.requiredRules.length; i++) {
            (bool callNotReverted,) = rulesToProcess.requiredRules[i].call(
                abi.encodeCall(
                    IPostRule.processParent,
                    (rootPostId, parentPostId, postId, parentPostRulesData.dataForRequiredRules[i])
                )
            );
            require(callNotReverted, "Some required rule failed");
        }
        // Check any-of rules (OR-combined rules)
        if (rulesToProcess.anyOfRules.length == 0) {
            return; // If there are no OR-combined rules, we can return
        }
        for (uint256 i = 0; i < rulesToProcess.anyOfRules.length; i++) {
            (bool callNotReverted, bytes memory returnData) = rulesToProcess.anyOfRules[i].call(
                abi.encodeCall(
                    IPostRule.processParent,
                    (rootPostId, parentPostId, postId, parentPostRulesData.dataForAnyOfRules[i])
                )
            );
            if (callNotReverted && abi.decode(returnData, (bool))) {
                // Note: abi.decode would fail if call reverted, so don't put this out of the brackets!
                return; // If any of the OR-combined rules passed, it means they succeed and we can return
            }
        }
        revert("All of the OR rules failed");
    }

    function _processPostCreation(uint256 postId, uint256 localSequentialId, CreatePostParams calldata postParams)
        internal
    {
        // Check required rules (AND-combined rules)
        for (uint256 i = 0; i < $feedRulesStorage().requiredRules.length; i++) {
            (bool callNotReverted,) = $feedRulesStorage().requiredRules[i].call(
                abi.encodeCall(IFeedRule.processCreatePost, (postId, localSequentialId, postParams))
            );
            require(callNotReverted, "Some required rule failed");
        }
        // Check any-of rules (OR-combined rules)
        if ($feedRulesStorage().anyOfRules.length == 0) {
            return; // If there are no OR-combined rules, we can return
        }
        for (uint256 i = 0; i < $feedRulesStorage().anyOfRules.length; i++) {
            (bool callNotReverted, bytes memory returnData) = $feedRulesStorage().anyOfRules[i].call(
                abi.encodeCall(IFeedRule.processCreatePost, (postId, localSequentialId, postParams))
            );
            if (callNotReverted && abi.decode(returnData, (bool))) {
                // Note: abi.decode would fail if call reverted, so don't put this out of the brackets!
                return; // If any of the OR-combined rules passed, it means they succeed and we can return
            }
        }
        revert("All of the OR rules failed");
    }

    // TODO: FIX THIS!!!
    function _feedProcessCreateRepost(
        uint256 postId,
        uint256 localSequentialId,
        CreateRepostParams calldata repostParams
    ) internal {
        // Check required rules (AND-combined rules)
        for (uint256 i = 0; i < $feedRulesStorage().requiredRules.length; i++) {
            (bool callNotReverted,) = $feedRulesStorage().requiredRules[i].call(
                abi.encodeCall(IFeedRule.processCreatePost, (postId, localSequentialId, repostParams))
            );
            require(callNotReverted, "Some required rule failed");
        }
        // Check any-of rules (OR-combined rules)
        if ($feedRulesStorage().anyOfRules.length == 0) {
            return; // If there are no OR-combined rules, we can return
        }
        for (uint256 i = 0; i < $feedRulesStorage().anyOfRules.length; i++) {
            (bool callNotReverted, bytes memory returnData) = $feedRulesStorage().anyOfRules[i].call(
                abi.encodeCall(IFeedRule.processCreatePost, (postId, localSequentialId, repostParams))
            );
            if (callNotReverted && abi.decode(returnData, (bool))) {
                // Note: abi.decode would fail if call reverted, so don't put this out of the brackets!
                return; // If any of the OR-combined rules passed, it means they succeed and we can return
            }
        }
        revert("All of the OR rules failed");
    }

    function _feedProcessEditPost(
        uint256 postId,
        EditPostParams calldata newPostParams,
        RuleExecutionData calldata feedRulesData
    ) internal {
        // Check required rules (AND-combined rules)
        for (uint256 i = 0; i < $feedRulesStorage().requiredRules.length; i++) {
            (bool callNotReverted,) = $feedRulesStorage().requiredRules[i].call(
                abi.encodeCall(
                    IFeedRule.processEditPost, (postId, newPostParams, feedRulesData.dataForRequiredRules[i])
                )
            );
            require(callNotReverted, "Some required rule failed");
        }
        // Check any-of rules (OR-combined rules)
        if ($feedRulesStorage().anyOfRules.length == 0) {
            return; // If there are no OR-combined rules, we can return
        }
        for (uint256 i = 0; i < $feedRulesStorage().anyOfRules.length; i++) {
            (bool callNotReverted, bytes memory returnData) = $feedRulesStorage().anyOfRules[i].call(
                abi.encodeCall(IFeedRule.processEditPost, (postId, newPostParams, feedRulesData.dataForAnyOfRules[i]))
            );
            if (callNotReverted && abi.decode(returnData, (bool))) {
                // Note: abi.decode would fail if call reverted, so don't put this out of the brackets!
                return; // If any of the OR-combined rules passed, it means they succeed and we can return
            }
        }
        revert("All of the OR rules failed");
    }

    function _feedProcessDeletePost(uint256 postId, RuleExecutionData calldata feedRulesData) internal {
        // Check required rules (AND-combined rules)
        for (uint256 i = 0; i < $feedRulesStorage().requiredRules.length; i++) {
            (bool callNotReverted,) = $feedRulesStorage().requiredRules[i].call(
                abi.encodeCall(IFeedRule.processDeletePost, (postId, feedRulesData.dataForRequiredRules[i]))
            );
            require(callNotReverted, "Some required rule failed");
        }
        // Check any-of rules (OR-combined rules)
        if ($feedRulesStorage().anyOfRules.length == 0) {
            return; // If there are no OR-combined rules, we can return
        }
        for (uint256 i = 0; i < $feedRulesStorage().anyOfRules.length; i++) {
            (bool callNotReverted, bytes memory returnData) = $feedRulesStorage().anyOfRules[i].call(
                abi.encodeCall(IFeedRule.processDeletePost, (postId, feedRulesData.dataForAnyOfRules[i]))
            );
            if (callNotReverted && abi.decode(returnData, (bool))) {
                // Note: abi.decode would fail if call reverted, so don't put this out of the brackets!
                return; // If any of the OR-combined rules passed, it means they succeed and we can return
            }
        }
        revert("All of the OR rules failed");
    }

    function _processChangesOnPostRules(
        address author,
        uint256 postId,
        RuleConfiguration[] calldata newPostRules,
        RuleExecutionData calldata feedRulesData
    ) internal {
        // Check required rules (AND-combined rules)
        for (uint256 i = 0; i < $feedRulesStorage().requiredRules.length; i++) {
            (bool callNotReverted,) = $feedRulesStorage().requiredRules[i].call(
                abi.encodeCall(
                    IFeedRule.processPostRulesChanged,
                    (author, postId, newPostRules, feedRulesData.dataForRequiredRules[i])
                )
            );
            require(callNotReverted, "Some required rule failed");
        }
        // Check any-of rules (OR-combined rules)
        if ($feedRulesStorage().anyOfRules.length == 0) {
            return; // If there are no OR-combined rules, we can return
        }
        for (uint256 i = 0; i < $feedRulesStorage().anyOfRules.length; i++) {
            (bool callNotReverted, bytes memory returnData) = $feedRulesStorage().anyOfRules[i].call(
                abi.encodeCall(
                    IFeedRule.processPostRulesChanged,
                    (author, postId, newPostRules, feedRulesData.dataForAnyOfRules[i])
                )
            );
            if (callNotReverted && abi.decode(returnData, (bool))) {
                // Note: abi.decode would fail if call reverted, so don't put this out of the brackets!
                return; // If any of the OR-combined rules passed, it means they succeed and we can return
            }
        }
        revert("All of the OR rules failed");
    }

    function _getFeedRules(bool isRequired) internal view returns (address[] memory) {
        return $feedRulesStorage().getRulesArray(isRequired);
    }

    function _getPostRules(uint256 postId, bool isRequired) internal view returns (address[] memory) {
        return $postRulesStorage(postId).getRulesArray(isRequired);
    }
}
