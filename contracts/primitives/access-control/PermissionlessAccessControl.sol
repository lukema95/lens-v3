// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccessControl} from "./IAccessControl.sol";
import {Events} from "./../../types/Events.sol";

contract PermissionlessAccessControl is IAccessControl {
    constructor() {
        emit Events.Lens_Contract_Deployed(
            "access-control",
            "lens.access-control.permissionless",
            "access-control",
            "lens.access-control.permissionless"
        );
    }

    function hasAccess(address, /* account */ address, /* resourceLocation */ uint256 /* resourceId */ )
        external
        pure
        override
        returns (bool)
    {
        return true;
    }
}
