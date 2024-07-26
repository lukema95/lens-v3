// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IRoleBasedAccessControl} from './IRoleBasedAccessControl.sol';

contract BasicHierarchyAccessControl is IRoleBasedAccessControl {
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

    address public owner;

    mapping(address => Role) public _roles;

    function setRole(address account, uint256 roleId, bytes calldata data) external override {
        // Implement it so it has into account the NONE < MODERATOR < ADMIN < OWNER hierarchy.
    }

    function hasRole(address account, uint256 roleId) external view override returns (bool) {
        return _roles[account] == Role(roleId);
    }

    function getRole(address account) external view override returns (uint256) {
        return uint256(_roles[account]);
    }

    function hasAccess(
        address account,
        address resourceLocation,
        uint256 resourceId,
        bytes calldata data
    ) external view override returns (bool) {}

    function hasAccess(
        uint256 roleId,
        address resourceLocation,
        uint256 resourceId,
        bytes calldata data
    ) external view override returns (bool) {}

    function setGlobalAccess(
        uint256 roleId,
        uint256 resourceId,
        AccessPermission accessPermission,
        bytes calldata data
    ) external override {}

    function setScopedAccess(
        uint256 roleId,
        address resourceLocation,
        uint256 resourceId,
        AccessPermission accessPermission,
        bytes calldata data
    ) external override {}

    function getGlobalAccess(uint256 roleId, uint256 resourceId) external view override returns (AccessPermission) {}

    function getGlobalAccess(address account, uint256 resourceId) external view override returns (AccessPermission) {}

    function getScopedAccess(
        uint256 roleId,
        address resourceLocation,
        uint256 resourceId
    ) external view override returns (AccessPermission) {}

    function getScopedAccess(
        address account,
        address resourceLocation,
        uint256 resourceId
    ) external view override returns (AccessPermission) {}
}
