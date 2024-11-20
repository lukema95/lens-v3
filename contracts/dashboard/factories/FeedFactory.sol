// SPDX-License-Identifier: UNLICENSED
// Copyright (C) 2024 Lens Labs. All Rights Reserved.
pragma solidity ^0.8.0;

import {IAccessControl} from "./../../core/interfaces/IAccessControl.sol";
import {Feed} from "./../../core/primitives/feed/Feed.sol";
import {RoleBasedAccessControl} from "./../../core/access/RoleBasedAccessControl.sol";
import {RuleChange, DataElement, RuleConfiguration, RuleOperation} from "./../../core/types/Types.sol";
import {IFeedRule} from "./../../core/interfaces/IFeedRule.sol";

contract FeedFactory {
    event Lens_FeedFactory_Deployment(address indexed feed, string metadataURI);

    IAccessControl internal immutable _factoryOwnedAccessControl;
    IFeedRule internal immutable _userBlockingRule;

    constructor(address userBlockingRule) {
        _factoryOwnedAccessControl = new RoleBasedAccessControl({owner: address(this)});
        _userBlockingRule = IFeedRule(userBlockingRule);
    }

    function deployFeed(
        string memory metadataURI,
        IAccessControl accessControl,
        RuleChange[] calldata rules,
        DataElement[] calldata extraData
    ) external returns (address) {
        Feed feed = new Feed(metadataURI, _factoryOwnedAccessControl);
        RuleChange[] memory userBlockingRule = new RuleChange[](1);
        userBlockingRule[0] = RuleChange({
            configuration: RuleConfiguration({ruleAddress: address(_userBlockingRule), configData: "", isRequired: true}),
            operation: RuleOperation.ADD
        });
        feed.changeFeedRules(userBlockingRule);
        feed.changeFeedRules(rules);
        feed.setExtraData(extraData);
        feed.setAccessControl(accessControl);
        emit Lens_FeedFactory_Deployment(address(feed), metadataURI);
        return address(feed);
    }
}
