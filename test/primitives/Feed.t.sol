// SPDX-License-Identifier: UNLICENSED
// Copyright (C) 2024 Lens Labs. All Rights Reserved.
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import {IAccessControl} from "@core/interfaces/IAccessControl.sol";
import {OwnerAdminOnlyAccessControl} from "@dashboard/access/OwnerAdminOnlyAccessControl.sol";
import {RuleExecutionData, SourceStamp} from "@core/types/Types.sol";
import "../helpers/TypeHelpers.sol";
import {Feed} from "@core/primitives/Feed/Feed.sol";
import {IFeed, CreatePostParams, EditPostParams} from "@core/interfaces/IFeed.sol";

contract FeedTest is Test {
    IAccessControl accessControl;
    IFeed feed;

    address author = makeAddr("AUTHOR");

    function setUp() public {
        accessControl = new OwnerAdminOnlyAccessControl(address(this));
        feed = new Feed({metadataURI: "uri://feed-metadata", accessControl: IAccessControl(accessControl)});
    }

    function testPost() public {
        vm.prank(author);
        uint256 postId = feed.createPost(
            CreatePostParams({
                author: author,
                contentURI: "some content uri",
                repostedPostId: 0,
                quotedPostId: 0,
                repliedPostId: 0,
                rules: _emptyRuleConfigurationArray(),
                feedRulesData: _emptyExecutionData(),
                repostedPostRulesData: _emptyExecutionData(),
                quotedPostRulesData: _emptyExecutionData(),
                repliedPostRulesData: _emptyExecutionData(),
                extraData: _emptyExtraData()
            }),
            _emptySourceStamp()
        );

        vm.prank(author);
        feed.editPost(
            postId,
            EditPostParams({contentURI: "some new content uri", extraData: _emptyExtraData()}),
            _emptyExecutionData(),
            _emptySourceStamp()
        );

        vm.prank(author);
        feed.deletePost(postId, _emptyBytes32Array(), _emptyExecutionData(), _emptySourceStamp());
    }

    function testEditNonExistentPost() public {
        uint256 nonExistentPostId = 9999;
        vm.prank(author);
        vm.expectRevert("POST_DOES_NOT_EXIST");
        feed.editPost(
            nonExistentPostId,
            EditPostParams({contentURI: "some new content uri", extraData: _emptyExtraData()}),
            _emptyExecutionData(),
            _emptySourceStamp()
        );
    }
}
