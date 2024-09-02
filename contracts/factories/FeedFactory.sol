// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccessControl} from "./../primitives/access-control/IAccessControl.sol";
import {Feed} from "./../primitives/feed/Feed.sol";
import {OwnerOnlyAccessControl} from "./../primitives/access-control/OwnerOnlyAccessControl.sol";
import {FeedRuleCombinator} from "./../primitives/feed/FeedRuleCombinator.sol";
import {IFeedRule} from "./../primitives/feed/IFeedRule.sol";

contract FeedFactory {
    event Lens_FeedFactory_NewFeedInstance(
        address indexed feedInstance,
        string metadataURI,
        IAccessControl accessControl,
        IFeedRule rules,
        bytes rulesInitializationData
    );

    IAccessControl internal _accessControl;
    IAccessControl internal immutable _factoryOwnedAccessControl;

    uint256 constant CHANGE_ACCESS_CONTROL_RID = uint256(keccak256("CHANGE_ACCESS_CONTROL"));
    uint256 constant DEPLOY_FEED_RID = uint256(keccak256("DEPLOY_FEED"));

    function setAccessControl(IAccessControl accessControl) external {
        require(
            IAccessControl(_accessControl).hasAccess({
                account: msg.sender,
                resourceLocation: address(this),
                resourceId: CHANGE_ACCESS_CONTROL_RID
            })
        ); // msg.sender must have permissions to change access control
        accessControl.hasAccess(address(0), address(0), 0); // We expect this to not panic.
        _accessControl = accessControl;
    }

    constructor(IAccessControl accessControl) {
        _accessControl = accessControl;
        _factoryOwnedAccessControl = new OwnerOnlyAccessControl({owner: address(this)});
    }

    function deploy__Immutable_NoRules(string memory metadataURI, IAccessControl accessControl)
        external
        returns (address)
    {
        require(
            IAccessControl(_accessControl).hasAccess({
                account: msg.sender,
                resourceLocation: address(this),
                resourceId: DEPLOY_FEED_RID
            })
        ); // msg.sender must have permissions to deploy FeedPrimitive
        address feedInstance = address(new Feed(metadataURI, accessControl));
        emit Lens_FeedFactory_NewFeedInstance({
            feedInstance: feedInstance,
            metadataURI: metadataURI,
            accessControl: accessControl,
            rules: IFeedRule(address(0)),
            rulesInitializationData: ""
        });
        return feedInstance;
    }

    function deploy__Immutable_WithRules(
        string memory metadataURI,
        IAccessControl accessControl,
        bytes calldata rulesInitializationData
    ) external returns (address) {
        require(
            IAccessControl(_accessControl).hasAccess({
                account: msg.sender,
                resourceLocation: address(this),
                resourceId: DEPLOY_FEED_RID
            })
        ); // msg.sender must have permissions to deploy
        Feed feedInstance = new Feed(metadataURI, _factoryOwnedAccessControl);
        IFeedRule rulesInstance = new FeedRuleCombinator();
        rulesInstance.configure(rulesInitializationData);
        feedInstance.setFeedRules(rulesInstance);
        feedInstance.setAccessControl(accessControl);
        emit Lens_FeedFactory_NewFeedInstance({
            feedInstance: address(feedInstance),
            metadataURI: metadataURI,
            accessControl: accessControl,
            rules: rulesInstance,
            rulesInitializationData: rulesInitializationData
        });
        return address(feedInstance);
    }
}
