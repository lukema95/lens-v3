// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IRoleBasedAccessControl} from "./IRoleBasedAccessControl.sol";
import {Ownership} from "./../../diamond/Ownership.sol";

/**
 * This Access Control:
 * - Has only two roles: Owner and Admin.
 * - There is only a single Owner.
 * - There can be multiple Admins.
 * - Owners can do everything.
 * - Admins can do everything except changing roles (adding or removing Admins or Owners).
 */

// contract AdminOnlyAccessControl is Ownership, IRoleBasedAccessControl {
//     mapping(address => bool) internal _isAdmin;

//     constructor(address owner) Ownership(owner) {}

//     function hasAccess(
//         address account,
//         address /* resourceLocation */,
//         uint256 /* resourceId */
//     ) external view override returns (bool) {
//         return _isAdmin[account] || account == _owner;
//     }
// }
