// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IRoleBasedAccessControl} from "./../primitives/access-control/IRoleBasedAccessControl.sol";
import {IAccessControl} from "./../primitives/access-control/IAccessControl.sol";
import {Group} from "./../primitives/group/Group.sol";
import {OwnerOnlyAccessControl} from "./../primitives/access-control/OwnerOnlyAccessControl.sol";
import {RoleBasedAccessControl} from "./../primitives/access-control/RoleBasedAccessControl.sol";
import {RuleConfiguration, DataElement} from "./../types/Types.sol";
import {GroupFactory} from "./GroupFactory.sol";
import {FeedFactory} from "./FeedFactory.sol";
import {GraphFactory} from "./GraphFactory.sol";
import {UsernameFactory} from "./UsernameFactory.sol";
import {AppFactory, AppInitialProperties} from "./AppFactory.sol";

// struct RoleConfiguration {
//     uint256 roleId;
//     address[] accounts;
// }

// struct AccessConfiguration {
//     uint256 resourceId;
//     address resourceLocation;
//     uint256 roleId;
//     IRoleBasedAccessControl.AccessPermission accessPermission;
// }

// uint8 decimals; TODO ???

contract LensFactory {
    uint256 immutable ADMIN_ROLE_ID = uint256(keccak256("ADMIN"));
    AppFactory internal immutable APP_FACTORY;
    GroupFactory internal immutable GROUP_FACTORY;
    FeedFactory internal immutable FEED_FACTORY;
    GraphFactory internal immutable GRAPH_FACTORY;
    UsernameFactory internal immutable USERNAME_FACTORY;
    IAccessControl internal immutable _factoryOwnedAccessControl;

    constructor(
        AppFactory appFactory,
        GroupFactory groupFactory,
        FeedFactory feedFactory,
        GraphFactory graphFactory,
        UsernameFactory usernameFactory
    ) {
        APP_FACTORY = appFactory;
        GROUP_FACTORY = groupFactory;
        FEED_FACTORY = feedFactory;
        GRAPH_FACTORY = graphFactory;
        USERNAME_FACTORY = usernameFactory;
        _factoryOwnedAccessControl = new OwnerOnlyAccessControl({owner: address(this)});
    }

    function deployApp(
        string memory metadataURI,
        address owner,
        address[] calldata admins,
        AppInitialProperties calldata initialProperties,
        DataElement[] calldata extraData
    ) external returns (address) {
        return APP_FACTORY.deployApp(metadataURI, _deployAccessControl(owner, admins), initialProperties, extraData);
    }

    function deployGroup(
        string memory metadataURI,
        address owner,
        address[] calldata admins,
        RuleConfiguration[] calldata rules,
        DataElement[] calldata extraData
    ) external returns (address) {
        return GROUP_FACTORY.deployGroup(metadataURI, _deployAccessControl(owner, admins), rules, extraData);
    }

    function deployFeed(
        string memory metadataURI,
        address owner,
        address[] calldata admins,
        RuleConfiguration[] calldata rules,
        DataElement[] calldata extraData
    ) external returns (address) {
        return FEED_FACTORY.deployFeed(metadataURI, _deployAccessControl(owner, admins), rules, extraData);
    }

    function deployGraph(
        string memory metadataURI,
        address owner,
        address[] calldata admins,
        RuleConfiguration[] calldata rules,
        DataElement[] calldata extraData
    ) external returns (address) {
        return GRAPH_FACTORY.deployGraph(metadataURI, _deployAccessControl(owner, admins), rules, extraData);
    }

    function deployUsername(
        string memory namespace,
        string memory metadataURI,
        address owner,
        address[] calldata admins,
        RuleConfiguration[] calldata rules,
        DataElement[] calldata extraData
    ) external returns (address) {
        return USERNAME_FACTORY.deployUsername(
            namespace, metadataURI, _deployAccessControl(owner, admins), rules, extraData
        );
    }

    // function deployRoleBasedAccessControl(
    //     address owner,
    //     RoleConfiguration[] calldata roleConfigs,
    //     AccessConfiguration[] calldata accessConfigs
    // ) external returns (address) {
    //     RoleBasedAccessControl accessControl = new RoleBasedAccessControl({owner: address(this)});
    //     for (uint256 i = 0; i < roleConfigs.length; i++) {
    //         for (uint256 j = 0; j < roleConfigs[i].accounts.length; j++) {
    //             accessControl.grantRole(roleConfigs[i].accounts[j], roleConfigs[i].roleId);
    //         }
    //     }
    //     for (uint256 i = 0; i < accessConfigs.length; i++) {
    //         if (accessConfigs[i].resourceLocation == address(0)) {
    //             accessControl.setGlobalAccess(
    //                 accessConfigs[i].roleId, accessConfigs[i].resourceId, accessConfigs[i].accessPermission, ""
    //             );
    //         } else {
    //             accessControl.setScopedAccess(
    //                 accessConfigs[i].roleId,
    //                 accessConfigs[i].resourceLocation,
    //                 accessConfigs[i].resourceId,
    //                 accessConfigs[i].accessPermission,
    //                 ""
    //             );
    //         }
    //     }
    //     accessControl.transferOwnership(owner);
    //     return address(accessControl);
    // }

    function _deployAccessControl(address owner, address[] calldata admins)
        internal
        returns (IRoleBasedAccessControl)
    {
        RoleBasedAccessControl accessControl = new RoleBasedAccessControl({owner: address(this)});
        for (uint256 i = 0; i < admins.length; i++) {
            accessControl.grantRole(admins[i], ADMIN_ROLE_ID);
        }
        accessControl.transferOwnership(owner);
        return accessControl;
    }
}
