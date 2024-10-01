// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccessControl} from "./../primitives/access-control/IAccessControl.sol";
import {Community} from "./../primitives/community/Community.sol";
import {OwnerOnlyAccessControl} from "./../primitives/access-control/OwnerOnlyAccessControl.sol";
import {RuleConfiguration} from "./../types/Types.sol";

contract CommunityFactory {
    event Lens_CommunityFactory_Deployment(address indexed community);

    IAccessControl internal immutable _factoryOwnedAccessControl;

    constructor() {
        _factoryOwnedAccessControl = new OwnerOnlyAccessControl({owner: address(this)});
    }

    function deploy(string memory metadataURI, IAccessControl accessControl, RuleConfiguration[] calldata rules)
        external
        returns (address)
    {
        Community community = new Community(metadataURI, _factoryOwnedAccessControl);
        community.addCommunityRules(rules);
        community.setAccessControl(accessControl);
        emit Lens_CommunityFactory_Deployment(address(community));
        return address(community);
    }
}
