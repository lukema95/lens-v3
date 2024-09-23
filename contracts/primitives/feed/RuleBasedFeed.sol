// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IPostRule} from "./IPostRule.sol";
import {IFeedRule} from "./IFeedRule.sol";
import {RulesStorage, RulesLib} from "./../base/RulesLib.sol";
import {RuleConfiguration, RuleExecutionData} from "./../../types/Types.sol";

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
        $feedRulesStorage().addRule(rule, abi.encodeWithSelector(IFeedRule.configure.selector, rule.configData));
    }

    function _updateFeedRule(RuleConfiguration calldata rule) internal {
        $feedRulesStorage().updateRule(rule, abi.encodeWithSelector(IFeedRule.configure.selector, rule.configData));
    }

    function _removeFeedRule(address rule) internal {
        $feedRulesStorage().removeRule(rule);
    }

    function _feedProcessCreatePost(
        uint256 postId,
        uint256 localSequentialId,
        PostParams calldata postParams,
        RuleExecutionData calldata feedRulesData
    ) internal {
        _feedProcessPost(IFeedRule.processCreatePost.selector, postId, localSequentialId, postParams, feedRulesData);
    }

    function _feedProcessEditPost(
        uint256 postId,
        uint256 localSequentialId,
        PostParams calldata newPostParams,
        RuleExecutionData calldata feedRulesData
    ) internal {
        _feedProcessPost(IFeedRule.processEditPost.selector, postId, localSequentialId, newPostParams, feedRulesData);
    }

    function _feedProcessPost(
        bytes4 selector,
        uint256 postId,
        uint256 localSequentialId,
        PostParams calldata postParams,
        RuleExecutionData calldata feedRulesData
    ) private {
        // Check required rules (AND-combined rules)
        for (uint256 i = 0; i < $feedRulesStorage().requiredRules.length; i++) {
            (bool callNotReverted,) = $feedRulesStorage().requiredRules[i].call(
                abi.encodeWithSelector(
                    selector, postId, localSequentialId, postParams, feedRulesData.dataForRequiredRules[i]
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
                abi.encodeWithSelector(
                    selector, postId, localSequentialId, postParams, feedRulesData.dataForAnyOfRules[i]
                )
            );
            if (callNotReverted && abi.decode(returnData, (bool))) {
                // Note: abi.decode would fail if call reverted, so don't put this out of the brackets!
                return; // If any of the OR-combined rules passed, it means they succeed and we can return
            }
        }
        revert("All of the OR rules failed");
    }

    function _feedProcessDeletePost(uint256 postId, uint256 localSequentialId, RuleExecutionData calldata feedRulesData)
        internal
    {
        // Check required rules (AND-combined rules)
        for (uint256 i = 0; i < $feedRulesStorage().requiredRules.length; i++) {
            (bool callNotReverted,) = $feedRulesStorage().requiredRules[i].call(
                abi.encodeWithSelector(
                    IFeedRule.processDeletePost.selector,
                    postId,
                    localSequentialId,
                    feedRulesData.dataForRequiredRules[i]
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
                abi.encodeWithSelector(
                    IFeedRule.processDeletePost.selector, postId, localSequentialId, feedRulesData.dataForAnyOfRules[i]
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
