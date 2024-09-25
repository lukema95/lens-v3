// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IRoleBasedAccessControl} from "./IRoleBasedAccessControl.sol";
import {Ownership} from "./../../diamond/Ownership.sol";
import {Events} from "./../../types/Events.sol";

/**
 * This Access Control:
 * - Has only two roles: Owner and Admin.
 * - There is only a single Owner.
 * - There can be multiple Admins.
 * - Owners can do everything.
 * - Admins can do everything except changing roles (adding or removing Admins or Owners).
 */
// TODO: Find a better name?
// TODO: Ask if we should pre-grant everything but still allow to revoke certain things manually for the Admins.
contract OwnerAdminAccessControl is Ownership, IRoleBasedAccessControl {
    /**
     * This event is expected to be used to identify the type of the access control implementation, which in this case
     * allows the indexers to know that Owners and Admins have pre-granted access to all resources.
     */
    event Lens_OwnerAdminAccessControl_Created();

    enum Role {
        NONE, /////// 0 - Nothing.
        ADMIN, ////// 1 - Everything but adding or revoking roles.
        OWNER /////// 2 - Everything.

    }

    mapping(address => bool) internal _isAdmin;

    constructor(address owner) Ownership(owner) {
        emit Lens_OwnerAdminAccessControl_Created();
        emit Lens_AccessControl_RoleSet(owner, uint256(Role.OWNER));
        emit Events.Lens_Contract_Deployed(
            "access-control", "lens.access-control.owner-admin", "access-control", "lens.access-control.owner-admin"
        );
    }

    function hasAccess(address account, address, /* resourceLocation */ uint256 /* resourceId */ )
        external
        view
        override
        returns (bool)
    {
        return _isAdmin[account] || account == _owner;
    }

    function setRole(address account, uint256 roleId, bytes calldata /* data */ ) external override onlyOwner {
        require(account != _owner);
        require(roleId == uint256(Role.ADMIN) || roleId == uint256(Role.NONE));
        _isAdmin[account] = roleId == uint256(Role.ADMIN);
        emit Lens_AccessControl_RoleSet(account, roleId);
    }

    function hasRole(address account, uint256 roleId) external view override returns (bool) {
        if (roleId == uint256(Role.OWNER)) {
            return account == _owner;
        } else if (roleId == uint256(Role.ADMIN)) {
            return _isAdmin[account];
        } else {
            return false;
        }
    }

    function getRole(address account) external view override returns (uint256) {
        if (_isAdmin[account]) {
            return uint256(Role.ADMIN);
        } else if (account == _owner) {
            return uint256(Role.OWNER);
        } else {
            return uint256(Role.NONE);
        }
    }

    function setGlobalAccess(
        uint256, /* roleId */
        uint256, /* resourceId */
        AccessPermission, /* accessPermission */
        bytes calldata /* data */
    ) external pure override {
        revert(); // Access is pre-defined for this implementation.
    }

    function setScopedAccess(
        uint256, /* roleId */
        address, /* resourceLocation */
        uint256, /* resourceId */
        AccessPermission, /* accessPermission */
        bytes calldata /* data */
    ) external pure override {
        revert(); // Access is pre-defined for this implementation.
    }

    function getGlobalAccess(uint256 roleId, uint256 /* resourceId */ )
        external
        pure
        override
        returns (AccessPermission)
    {
        return _getAccessByRoleId(roleId);
    }

    function getGlobalAccess(address account, uint256 /* resourceId */ )
        external
        view
        override
        returns (AccessPermission)
    {
        return _getAccessByAccount(account);
    }

    function getScopedAccess(uint256 roleId, address, /* resourceLocation */ uint256 /* resourceId */ )
        external
        pure
        override
        returns (AccessPermission)
    {
        return _getAccessByRoleId(roleId);
    }

    function getScopedAccess(address account, address, /* resourceLocation */ uint256 /* resourceId */ )
        external
        view
        override
        returns (AccessPermission)
    {
        return _getAccessByAccount(account);
    }

    function _getAccessByAccount(address account) internal view returns (AccessPermission) {
        if (_isAdmin[account]) {
            return _getAccessByRoleId(uint256(Role.ADMIN));
        } else if (account == _owner) {
            return _getAccessByRoleId(uint256(Role.OWNER));
        } else {
            return _getAccessByRoleId(uint256(Role.NONE));
        }
    }

    function _getAccessByRoleId(uint256 roleId) internal pure returns (AccessPermission) {
        if (roleId == uint256(Role.OWNER) || roleId == uint256(Role.ADMIN)) {
            return AccessPermission.GRANTED;
        } else {
            return AccessPermission.UNDEFINED;
        }
    }

    function _confirmOwnershipTransfer(address newOwner) internal virtual override returns (address) {
        emit Lens_AccessControl_RoleSet(_owner, uint256(Role.NONE));
        emit Lens_AccessControl_RoleSet(newOwner, uint256(Role.OWNER));
        return super._confirmOwnershipTransfer(newOwner);
    }
}
