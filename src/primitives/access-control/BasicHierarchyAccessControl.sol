// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccessControl} from './IAccessControl.sol';

contract BasicHierarchyAccessControl is IAccessControl {
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

    function setRole(address account, uint256 roleId) external override {
        // Implement it so it has into account the NONE < MODERATOR < ADMIN < OWNER hierarchy.
    }

    function hasRole(address account, uint256 roleId) external view override returns (bool) {
        return _roles[account] == Role(roleId);
    }

    function getRole(address account) external view override returns (uint256) {
        return uint256(_roles[account]);
    }
}
