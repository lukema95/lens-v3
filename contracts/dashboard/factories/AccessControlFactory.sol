// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {OwnerAdminOnlyAccessControl} from "./../access/OwnerAdminOnlyAccessControl.sol";

contract AccessControlFactory {
    event Lens_AccessControlFactory_Deployment(address indexed accessControl, address owner);

    function deployOwnerAdminOnlyAccessControl(address owner) external returns (address) {
        address ac = address(new OwnerAdminOnlyAccessControl(owner));
        emit Lens_AccessControlFactory_Deployment(ac, owner);
        return address(ac);
    }
}
