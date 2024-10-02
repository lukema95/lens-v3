// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IRoleBasedAccessControl} from "./../primitives/access-control/IRoleBasedAccessControl.sol";
import {IAccessControl} from "./../primitives/access-control/IAccessControl.sol";
import {Community} from "./../primitives/community/Community.sol";
import {OwnerOnlyAccessControl} from "./../primitives/access-control/OwnerOnlyAccessControl.sol";
import {RoleBasedAccessControl} from "./../primitives/access-control/RoleBasedAccessControl.sol";
import {RuleConfiguration, DataElement} from "./../types/Types.sol";
import {CommunityFactory} from "./CommunityFactory.sol";
import {FeedFactory} from "./FeedFactory.sol";
import {GraphFactory} from "./GraphFactory.sol";
import {UsernameFactory} from "./UsernameFactory.sol";
import {AppFactory, InitialProperties} from "./AppFactory.sol";

struct RoleConfiguration {
    uint256 roleId;
    address[] accounts;
}

struct AccessConfiguration {
    uint256 resourceId;
    address resourceLocation;
    uint256 roleId;
    IRoleBasedAccessControl.AccessPermission accessPermission;
}

struct TokenizationConfiguration {
    bool tokenizationEnabled;
    string tokenName;
    string tokenSymbol;
    string baseURI;
}
// uint8 decimals; TODO ???

contract LensFactory {
    AppFactory internal immutable APP_FACTORY;
    CommunityFactory internal immutable COMMUNITY_FACTORY;
    FeedFactory internal immutable FEED_FACTORY;
    GraphFactory internal immutable GRAPH_FACTORY;
    UsernameFactory internal immutable USERNAME_FACTORY;
    IAccessControl internal immutable _factoryOwnedAccessControl;

    constructor(
        AppFactory appFactory,
        CommunityFactory communityFactory,
        FeedFactory feedFactory,
        GraphFactory graphFactory,
        UsernameFactory usernameFactory
    ) {
        APP_FACTORY = appFactory;
        COMMUNITY_FACTORY = communityFactory;
        FEED_FACTORY = feedFactory;
        GRAPH_FACTORY = graphFactory;
        USERNAME_FACTORY = usernameFactory;
        _factoryOwnedAccessControl = new OwnerOnlyAccessControl({owner: address(this)});
    }

    function deployApp(
        address owner,
        RoleConfiguration[] calldata roleConfigs,
        AccessConfiguration[] calldata accessConfigs,
        InitialProperties calldata initialProperties
    ) external returns (address) {
        return APP_FACTORY.deploy(_deployAccessControl(owner, roleConfigs, accessConfigs), initialProperties);
    }

    function deployCommunity(
        string memory metadataURI,
        address owner,
        RoleConfiguration[] calldata roleConfigs,
        AccessConfiguration[] calldata accessConfigs,
        RuleConfiguration[] calldata rules,
        DataElement[] calldata extraData,
        TokenizationConfiguration calldata tokenizationConfig
    ) external returns (address) {
        if (tokenizationConfig.tokenizationEnabled) {
            revert("NOT_IMPLEMENTED_YET");
        } else {
            return COMMUNITY_FACTORY.deploy(
                metadataURI, _deployAccessControl(owner, roleConfigs, accessConfigs), rules, extraData
            );
        }
    }

    function deployFeed(
        string memory metadataURI,
        address owner,
        RoleConfiguration[] calldata roleConfigs,
        AccessConfiguration[] calldata accessConfigs,
        RuleConfiguration[] calldata rules,
        DataElement[] calldata extraData
    ) external returns (address) {
        return
            FEED_FACTORY.deploy(metadataURI, _deployAccessControl(owner, roleConfigs, accessConfigs), rules, extraData);
    }

    function deployGraph(
        string memory metadataURI,
        address owner,
        RoleConfiguration[] calldata roleConfigs,
        AccessConfiguration[] calldata accessConfigs,
        RuleConfiguration[] calldata rules,
        DataElement[] calldata extraData
    ) external returns (address) {
        return
            GRAPH_FACTORY.deploy(metadataURI, _deployAccessControl(owner, roleConfigs, accessConfigs), rules, extraData);
    }

    function deployUsername(
        string memory namespace,
        string memory metadataURI,
        address owner,
        RoleConfiguration[] calldata roleConfigs,
        AccessConfiguration[] calldata accessConfigs,
        RuleConfiguration[] calldata rules,
        DataElement[] calldata extraData,
        TokenizationConfiguration calldata tokenizationConfig
    ) external returns (address) {
        if (tokenizationConfig.tokenizationEnabled) {
            revert("NOT_IMPLEMENTED_YET");
        } else {
            return USERNAME_FACTORY.deploy(
                namespace, metadataURI, _deployAccessControl(owner, roleConfigs, accessConfigs), rules, extraData
            );
        }
    }

    function _deployAccessControl(
        address owner,
        RoleConfiguration[] calldata roleConfigs,
        AccessConfiguration[] calldata accessConfigs
    ) internal returns (IRoleBasedAccessControl) {
        RoleBasedAccessControl accessControl = new RoleBasedAccessControl({owner: address(this)}); // TODO: We need the new access control implementation to be done!
        for (uint256 i = 0; i < roleConfigs.length; i++) {
            for (uint256 j = 0; j < roleConfigs[i].accounts.length; j++) {
                accessControl.grantRole(roleConfigs[i].accounts[j], roleConfigs[i].roleId);
            }
        }
        for (uint256 i = 0; i < accessConfigs.length; i++) {
            if (accessConfigs[i].resourceLocation == address(0)) {
                accessControl.setGlobalAccess(
                    accessConfigs[i].roleId, accessConfigs[i].resourceId, accessConfigs[i].accessPermission, ""
                );
            } else {
                accessControl.setScopedAccess(
                    accessConfigs[i].roleId,
                    accessConfigs[i].resourceLocation,
                    accessConfigs[i].resourceId,
                    accessConfigs[i].accessPermission,
                    ""
                );
            }
        }
        accessControl.transferOwnership(owner);
        return accessControl;
    }
}
