// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {CreatePostParams, EditPostParams} from "../../../primitives/feed/IFeed.sol";
import {IFeedRule} from "../IFeedRule.sol";
import {RuleConfiguration} from "../../../types/Types.sol";
import {IGroup} from "../../group/IGroup.sol";

contract GroupGatedFeedRule is IFeedRule {
    mapping(address => address) internal _groupGate;

    function configure(bytes calldata data) external override {
        _groupGate[msg.sender] = abi.decode(data, (address));
    }

    function processCreatePost(
        uint256, /* postId */
        uint256, /* localSequentialId */
        CreatePostParams calldata postParams,
        bytes calldata /* data */
    ) external view override returns (bool) {
        require(IGroup(_groupGate[msg.sender]).getMembershipId(postParams.author) != 0, "NotAMember()");
        return true;
    }

    function processEditPost(
        uint256, /* postId */
        uint256, /* localSequentialId */
        EditPostParams calldata, /* editPostParams */
        bytes calldata /* data */
    ) external pure override returns (bool) {
        return false;
    }

    function processDeletePost(uint256, /* postId */ uint256, /* localSequentialId */ bytes calldata /* data */ )
        external
        pure
        override
        returns (bool)
    {
        return false;
    }

    function processPostRulesChanged(
        uint256, /* postId */
        uint256, /* localSequentialId */
        RuleConfiguration[] calldata, /* newPostRules */
        bytes calldata /* data */
    ) external pure override returns (bool) {
        return false;
    }
}
