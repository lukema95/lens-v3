// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccessControl} from "./../primitives/access-control/IAccessControl.sol";
import {Group} from "./../primitives/group/Group.sol";
import {OwnerOnlyAccessControl} from "./../primitives/access-control/OwnerOnlyAccessControl.sol";
import {RuleConfiguration, DataElement} from "./../types/Types.sol";

contract GroupFactory {
    event Lens_GroupFactory_Deployment(address indexed group);

    IAccessControl internal immutable _factoryOwnedAccessControl;

    constructor() {
        _factoryOwnedAccessControl = new OwnerOnlyAccessControl({owner: address(this)});
    }

    function deployGroup(
        string memory metadataURI,
        IAccessControl accessControl,
        RuleConfiguration[] calldata rules,
        DataElement[] calldata extraData
    ) external returns (address) {
        Group group = new Group(metadataURI, _factoryOwnedAccessControl);
        group.addGroupRules(rules);
        group.setExtraData(extraData);
        group.setAccessControl(accessControl);
        emit Lens_GroupFactory_Deployment(address(group));
        return address(group);
    }
}
