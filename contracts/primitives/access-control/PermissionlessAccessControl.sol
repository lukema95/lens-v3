// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccessControl} from "./IAccessControl.sol";

contract PermissionlessAccessControl is IAccessControl {
    function hasAccess(
        address /* account */,
        address /* resourceLocation */,
        uint256 /* resourceId */
    ) external pure override returns (bool) {
        return true;
    }
}
