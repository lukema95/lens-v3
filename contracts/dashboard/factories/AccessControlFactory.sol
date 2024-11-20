// SPDX-License-Identifier: UNLICENSED
// Copyright (C) 2024 Lens Labs. All Rights Reserved.
pragma solidity ^0.8.0;

import {IRoleBasedAccessControl} from "./../../core/interfaces/IRoleBasedAccessControl.sol";
import {RoleBasedAccessControl} from "./../../core/access/RoleBasedAccessControl.sol";

contract AccessControlFactory {
    uint256 immutable ADMIN_ROLE_ID = uint256(keccak256("ADMIN"));

    event Lens_AccessControlFactory_OwnerAdminDeployment(address indexed accessControl, address owner);

    function deployOwnerAdminOnlyAccessControl(address owner, address[] calldata admins)
        external
        returns (IRoleBasedAccessControl)
    {
        RoleBasedAccessControl accessControl = new RoleBasedAccessControl({owner: address(this)});
        emit Lens_AccessControlFactory_OwnerAdminDeployment(address(accessControl), owner);
        for (uint256 i = 0; i < admins.length; i++) {
            accessControl.grantRole(admins[i], ADMIN_ROLE_ID);
        }
        accessControl.transferOwnership(owner);
        return accessControl;
    }
}
