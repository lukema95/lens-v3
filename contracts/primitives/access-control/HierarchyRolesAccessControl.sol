// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IRoleBasedAccessControl} from "./IRoleBasedAccessControl.sol";
import {Ownership} from "./../../diamond/Ownership.sol";
import {Events} from "./../../types/Events.sol";

contract HierarchyRolesAccessControl is Ownership, IRoleBasedAccessControl {
    enum Role {
        NONE, /////// 0 - No special control
        MODERATOR, // 1 - Soft control
        ADMIN, ////// 2 - Hard control
        OWNER /////// 3 - Full control

    }

    /**
     * Some examples of how can this be used in different primitives:
     *
     * [FEED]
     * NONE: Normal end user, does not have any special privilege.
     * MODERATOR: Can remove a post. Can promote a post. Can ban a user from publishing.
     * ADMIN: All MODERATOR stuff. Can change MODERATORS. Can also change or skip rules (if configured to allow skipping), and metadata.
     * OWNER: All ADMIN stuff. Can change ADMINs. Can change OWNER (transfer ownership).
     *
     * [USERNAME]
     * NONE: Normal end user, does not have any special privilege.
     * MODERATOR: Remove usernames containing bad words. Approve Trademarked usernames.
     * ADMIN: All MODERATOR stuff. Can change MODERATORS. Can also change or skip rules (if configured to allow skipping).
     * OWNER: All ADMIN stuff. Can change ADMINs. Can change OWNER (transfer ownership).
     *
     * [COMMUNITY]
     * NONE: Normal end user, does not have any special privilege.
     * MODERATOR: Can kick/ban people from the community.
     * ADMIN: All MODERATOR stuff. Can change MODERATORS. Can also change or skip rules (if configured to allow skipping).
     * OWNER: All ADMIN stuff. Can change ADMINs. Can change OWNER (transfer ownership).
     */
    mapping(address => Role) internal _roles;
    mapping(Role => mapping(uint256 => AccessPermission)) internal _globalAccess;
    mapping(Role => mapping(address => mapping(uint256 => AccessPermission))) internal _scopedAccess;

    constructor(address owner) Ownership(owner) {
        emit Events.Lens_Contract_Deployed(
            "access-control",
            "lens.access-control.hierarchy-roles",
            "access-control",
            "lens.access-control.hierarchy-roles"
        );
    }

    function _confirmOwnershipTransfer(address newOwner) internal virtual override returns (address) {
        address oldOwner = super._confirmOwnershipTransfer(newOwner);
        _roles[oldOwner] = Role.NONE;
        _roles[newOwner] = Role.OWNER;
        return oldOwner;
    }

    function hasAccess(address account, address resourceLocation, uint256 resourceId)
        external
        view
        override
        returns (bool)
    {
        // TODO: Implementas in the AddressBasedAccessControl instead of this. Move this to the _getScopedAccess, etc
        Role roleId = _roles[account];
        if (roleId == Role.OWNER) {
            return true;
        } else if (roleId == Role.NONE) {
            return false;
        } else {
            AccessPermission permission = _scopedAccess[roleId][resourceLocation][resourceId];
            if (permission == AccessPermission.UNDEFINED) {
                permission = _globalAccess[roleId][resourceId];
            }

            return permission == AccessPermission.GRANTED;
        }
    }

    function setRole(address account, uint256 roleId, bytes calldata data) external override {}

    function hasRole(address account, uint256 roleId) external view override returns (bool) {}

    function getRole(address account) external view override returns (uint256) {}

    function setGlobalAccess(uint256 roleId, uint256 resourceId, AccessPermission accessPermission, bytes calldata data)
        external
        override
    {}

    function setScopedAccess(
        uint256 roleId,
        address resourceLocation,
        uint256 resourceId,
        AccessPermission accessPermission,
        bytes calldata data
    ) external override {}

    function getGlobalAccess(uint256 roleId, uint256 resourceId) external view override returns (AccessPermission) {}

    function getGlobalAccess(address account, uint256 resourceId) external view override returns (AccessPermission) {}

    function getScopedAccess(uint256 roleId, address resourceLocation, uint256 resourceId)
        external
        view
        override
        returns (AccessPermission)
    {}

    function getScopedAccess(address account, address resourceLocation, uint256 resourceId)
        external
        view
        override
        returns (AccessPermission)
    {}
}
