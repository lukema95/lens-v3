// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccessControl} from "./../primitives/access-control/IAccessControl.sol";
import {Community} from "./../primitives/community/Community.sol";
import {OwnerOnlyAccessControl} from "./../primitives/access-control/OwnerOnlyAccessControl.sol";
import {CommunityRuleCombinator} from "./../primitives/community/CommunityRuleCombinator.sol";
import {ICommunityRule} from "./../primitives/community/ICommunityRule.sol";

contract CommunityFactory {
    IAccessControl internal _accessControl;
    IAccessControl internal immutable _factoryOwnedAccessControl;

    uint256 constant CHANGE_ACCESS_CONTROL_RID =
        uint256(keccak256("CHANGE_ACCESS_CONTROL"));
    uint256 constant DEPLOY_COMMUNITY_RID =
        uint256(keccak256("DEPLOY_COMMUNITY"));

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
        _factoryOwnedAccessControl = new OwnerOnlyAccessControl({
            owner: address(this)
        });
    }

    function deploy__Immutable_NoRules(
        string memory metadataURI,
        IAccessControl accessControl
    ) external returns (address) {
        require(
            IAccessControl(_accessControl).hasAccess({
                account: msg.sender,
                resourceLocation: address(this),
                resourceId: DEPLOY_COMMUNITY_RID
            })
        ); // msg.sender must have permissions to deploy CommunityPrimitive
        address communityInstance = address(
            new Community(metadataURI, accessControl)
        );
        return communityInstance;
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
                resourceId: DEPLOY_COMMUNITY_RID
            })
        ); // msg.sender must have permissions to deploy
        Community communityInstance = new Community(
            metadataURI,
            _factoryOwnedAccessControl
        );

        ICommunityRule rulesInstance = new CommunityRuleCombinator();
        rulesInstance.configure(rulesInitializationData);

        communityInstance.setCommunityRules(rulesInstance);

        communityInstance.setAccessControl(accessControl);

        return address(communityInstance);
    }
}
