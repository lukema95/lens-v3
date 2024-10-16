// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Events} from "./../../types/Events.sol";
import {RoleBasedAccessControl} from "./RoleBasedAccessControl.sol";

/**
 * This Access Control:
 * - Has two special pre-defined roles with pre-defined permissions: Owner and Admin.
 * - There is only a single Owner.
 * - There can be multiple Admins.
 * - Owner can do everything.
 * - Admins can do everything except changing roles (adding or removing Admins or Owners).
 */
contract OwnerAdminOnlyAccessControl is RoleBasedAccessControl {
    constructor(address owner) RoleBasedAccessControl(owner) {}

    function grantRole(address account, uint256 roleId) external virtual override {
        require(msg.sender == _owner);
        require(account != _owner);
        require(roleId == ADMIN_ROLE_ID);
        _isAdmin[account] = true;
        emit Lens_AccessControl_RoleGranted(account, roleId);
    }

    function setGlobalAccess(uint256, /* roleId */ uint256, /* permissionId */ Access /* access */ )
        external
        virtual
        override
    {
        revert();
    }

    function setScopedAccess(
        uint256, /* roleId */
        address, /* contractAddress */
        uint256, /* permissionId */
        Access /* access */
    ) external virtual override {
        revert();
    }

    function _emitLensContractDeployedEvent() internal virtual override {
        emit Events.Lens_Contract_Deployed(
            "access-control",
            "lens.access-control.owner-admin-only",
            "access-control",
            "lens.access-control.owner-admin-only"
        );
    }
}
