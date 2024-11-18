// SPDX-License-Identifier: UNLICENSED
// Copyright (C) 2024 Lens Labs. All Rights Reserved.
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "./helpers/TypeHelpers.sol";
import {IAccount, AccountManagerPermissions} from "@dashboard/account/IAccount.sol";
import {Account as AccountA} from "@dashboard/account/Account.sol";
import {Feed} from "@core/primitives/Feed/Feed.sol";
import {IFeed, Post, CreatePostParams} from "@core/interfaces/IFeed.sol";
import {OwnerAdminOnlyAccessControl} from "@dashboard/access/OwnerAdminOnlyAccessControl.sol";
import {IAccessControl} from "@core/interfaces/IAccessControl.sol";

contract AccountTest is Test {
    address owner = makeAddr("OWNER");
    address manager = makeAddr("MANAGER");

    IAccount account;
    IFeed feed;

    function setUp() public {
        address[] memory accountManagers = new address[](1);
        accountManagers[0] = manager;

        AccountManagerPermissions[] memory accountManagerPermissions = new AccountManagerPermissions[](1);
        accountManagerPermissions[0] = AccountManagerPermissions(true, true, true, true);

        account = IAccount(
            new AccountA({
                owner: owner,
                metadataURI: "uri://account-metadata",
                accountManagers: accountManagers,
                accountManagerPermissions: accountManagerPermissions,
                sourceStamp: _emptySourceStamp()
            })
        );

        IAccessControl accessControl = IAccessControl(new OwnerAdminOnlyAccessControl(address(this)));
        feed = new Feed({metadataURI: "uri://feed-metadata", accessControl: accessControl});
    }

    function testCanExecuteTxDirectly() public {
        bytes memory txData = abi.encodeCall(
            Feed.createPost,
            (
                CreatePostParams({
                    author: address(account),
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
            )
        );

        vm.prank(owner);
        bytes memory returnData = account.executeTransaction({to: address(feed), value: 0, data: txData});
        uint256 postId = abi.decode(returnData, (uint256));

        Post memory post = feed.getPost(postId);
        console.log("Post ContentURI:", post.contentURI);
        console.log("Post Author:", post.author);
    }

    function testCanExecuteTxViaManager() public {
        bytes memory txData = abi.encodeCall(
            Feed.createPost,
            (
                CreatePostParams({
                    author: address(account),
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
            )
        );

        vm.prank(manager);
        bytes memory returnData = account.executeTransaction({to: address(feed), value: 0, data: txData});
        uint256 postId = abi.decode(returnData, (uint256));

        Post memory post = feed.getPost(postId);
        console.log("Post ContentURI:", post.contentURI);
        console.log("Post Author:", post.author);
    }

    function testAccountErrorForwarding() public {
        address errorsTest = address(new ErrorsTest());

        vm.expectRevert("This is an error message");
        vm.prank(owner);
        account.executeTransaction({to: errorsTest, value: 0, data: abi.encodeCall(ErrorsTest.stringError, ())});

        vm.expectRevert(ErrorsTest.CustomError.selector);
        vm.prank(owner);
        account.executeTransaction({to: errorsTest, value: 0, data: abi.encodeCall(ErrorsTest.customError, ())});

        vm.expectRevert(abi.encodeWithSelector(ErrorsTest.CustomErrorWithValue.selector, uint256(123)));
        vm.prank(owner);
        account.executeTransaction({
            to: errorsTest,
            value: 0,
            data: abi.encodeWithSelector(ErrorsTest.customErrorWithValue.selector, uint256(123))
        });
    }
}

contract ErrorsTest {
    function stringError() public pure {
        revert("This is an error message");
    }

    error CustomError();

    function customError() public pure {
        revert CustomError();
    }

    error CustomErrorWithValue(uint256 value);

    function customErrorWithValue(uint256 value) public pure {
        revert CustomErrorWithValue(value);
    }
}
