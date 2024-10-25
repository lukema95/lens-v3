// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IRoleBasedAccessControl} from "./IRoleBasedAccessControl.sol";
import {Events} from "./../../types/Events.sol";

/**
 * This Access Control:
 * - Allows to add any custom role.
 * - Has two special pre-defined roles with pre-defined permissions: Owner and Admin.
 * - There is only a single Owner.
 * - There can be multiple Admins.
 * - Owners can do everything.
 * - Admins can do everything except changing roles (adding or removing Admins or Owners).
 * - When some account has many roles, access permission is the most permissive one (i.e. granted-overrides strategy).
 */
contract RoleBasedAccessControl is IRoleBasedAccessControl {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    uint256 immutable OWNER_ROLE_ID = uint256(keccak256("OWNER"));
    uint256 immutable ADMIN_ROLE_ID = uint256(keccak256("ADMIN")); // TODO: Consider moving this out from here.

    address internal _owner;
    mapping(address => bool) internal _isAdmin;
    mapping(address => uint256[]) internal _roles;
    mapping(uint256 => mapping(address => mapping(uint256 => Access))) internal _scopedAccess;
    mapping(uint256 => mapping(uint256 => Access)) internal _globalAccess;

    constructor(address owner) {
        _emitLensContractDeployedEvent();
        _owner = owner;
        emit Lens_AccessControl_RoleGranted(owner, OWNER_ROLE_ID);
    }

    function transferOwnership(address newOwner) external virtual {
        address oldOwner = _owner;
        require(msg.sender == _owner);
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function hasAccess(address account, address contractAddress, uint256 permissionId)
        external
        view
        virtual
        override
        returns (bool)
    {
        // `_getScopedAccess` always returns Access.GRANTED for Owner and Admins.
        Access scopedAccess = _getScopedAccess(account, contractAddress, permissionId);
        if (scopedAccess == Access.GRANTED) {
            return true;
        } else if (scopedAccess == Access.DENIED) {
            return false;
        } else {
            // scopedAccess == Access.UNDEFINED, so it depends exclusively on the global access.
            return _getGlobalAccess(account, permissionId) == Access.GRANTED;
        }
    }

    function grantRole(address account, uint256 roleId) external virtual override {
        require(msg.sender == _owner);
        require(account != _owner);
        if (roleId == OWNER_ROLE_ID) {
            revert();
        } else if (roleId == ADMIN_ROLE_ID) {
            _isAdmin[account] = true;
        } else {
            require(!_hasCustomRole(account, roleId));
            _roles[account].push(roleId);
        }
        emit Lens_AccessControl_RoleGranted(account, roleId);
    }

    function revokeRole(address account, uint256 roleId) external virtual override {
        require(msg.sender == _owner);
        require(account != _owner);
        if (roleId == OWNER_ROLE_ID) {
            revert();
        } else if (roleId == ADMIN_ROLE_ID) {
            _isAdmin[account] = false;
        } else {
            uint256 accountRolesLength = _roles[account].length;
            require(accountRolesLength > 0);
            uint256 roleIndex = 0;
            while (roleIndex < accountRolesLength) {
                if (_roles[account][roleIndex] == roleId) {
                    break;
                } else {
                    roleIndex++;
                }
            }
            require(roleIndex < accountRolesLength); // Index must be found before reaching the end of the array
            _roles[account][roleIndex] = _roles[account][accountRolesLength - 1];
            _roles[account].pop();
        }
        emit Lens_AccessControl_RoleRevoked(account, roleId);
    }

    function hasRole(address account, uint256 roleId) external view virtual override returns (bool) {
        if (roleId == ADMIN_ROLE_ID) {
            return account == _owner;
        } else if (roleId == ADMIN_ROLE_ID) {
            return _isAdmin[account];
        } else {
            return _hasCustomRole(account, roleId);
        }
    }

    function setGlobalAccess(uint256 roleId, uint256 permissionId, Access access) external virtual override {
        require(msg.sender == _owner);
        require(roleId != OWNER_ROLE_ID && roleId != ADMIN_ROLE_ID);
        Access previousPermission = _globalAccess[roleId][permissionId];
        _globalAccess[roleId][permissionId] = access;
        if (previousPermission == Access.UNDEFINED) {
            require(access != Access.UNDEFINED);
            emit Lens_AccessControl_GlobalAccessAdded(roleId, permissionId, access == Access.GRANTED);
        } else if (access == Access.UNDEFINED) {
            emit Lens_AccessControl_GlobalAccessRemoved(roleId, permissionId);
        } else {
            emit Lens_AccessControl_GlobalAccessUpdated(roleId, permissionId, access == Access.GRANTED);
        }
    }

    function setScopedAccess(uint256 roleId, address contractAddress, uint256 permissionId, Access access)
        external
        virtual
        override
    {
        require(msg.sender == _owner);
        require(roleId != OWNER_ROLE_ID && roleId != ADMIN_ROLE_ID);
        Access previousPermission = _scopedAccess[roleId][contractAddress][permissionId];
        _scopedAccess[roleId][contractAddress][permissionId] = access;
        if (previousPermission == Access.UNDEFINED) {
            require(access != Access.UNDEFINED);
            emit Lens_AccessControl_ScopedAccessAdded(roleId, contractAddress, permissionId, access == Access.GRANTED);
        } else if (access == Access.UNDEFINED) {
            emit Lens_AccessControl_ScopedAccessRemoved(roleId, contractAddress, permissionId);
        } else {
            emit Lens_AccessControl_ScopedAccessUpdated(roleId, contractAddress, permissionId, access == Access.GRANTED);
        }
    }

    function getGlobalAccess(uint256 roleId, uint256 permissionId) external view virtual override returns (Access) {
        return _globalAccess[roleId][permissionId];
    }

    function getGlobalAccess(address account, uint256 permissionId) external view virtual override returns (Access) {
        return _getGlobalAccess(account, permissionId);
    }

    function getScopedAccess(uint256 roleId, address contractAddress, uint256 permissionId)
        external
        view
        virtual
        override
        returns (Access)
    {
        return _scopedAccess[roleId][contractAddress][permissionId];
    }

    function getScopedAccess(address account, address contractAddress, uint256 permissionId)
        external
        view
        virtual
        override
        returns (Access)
    {
        return _getScopedAccess(account, contractAddress, permissionId);
    }

    function _hasCustomRole(address account, uint256 roleId) internal view virtual returns (bool) {
        for (uint256 i = 0; i < _roles[account].length; i++) {
            if (_roles[account][i] == roleId) {
                return true;
            }
        }
        return false;
    }

    function _getScopedAccess(address account, address contractAddress, uint256 permissionId)
        internal
        view
        virtual
        returns (Access)
    {
        if (_owner == account || _isAdmin[account]) {
            return Access.GRANTED;
        } else {
            Access access = Access.UNDEFINED;
            for (uint256 i = 0; i < _roles[account].length; i++) {
                if (_scopedAccess[_roles[account][i]][contractAddress][permissionId] == Access.DENIED) {
                    access = Access.DENIED;
                } else if (_scopedAccess[_roles[account][i]][contractAddress][permissionId] == Access.GRANTED) {
                    return Access.GRANTED;
                }
            }
            return access;
        }
    }

    function _getGlobalAccess(address account, uint256 permissionId) internal view virtual returns (Access) {
        if (_owner == account || _isAdmin[account]) {
            return Access.GRANTED;
        } else {
            Access access = Access.UNDEFINED;
            for (uint256 i = 0; i < _roles[account].length; i++) {
                if (_globalAccess[_roles[account][i]][permissionId] == Access.DENIED) {
                    access = Access.DENIED;
                } else if (_globalAccess[_roles[account][i]][permissionId] == Access.GRANTED) {
                    return Access.GRANTED;
                }
            }
            return access;
        }
    }

    function _emitLensContractDeployedEvent() internal virtual {
        emit Events.Lens_Contract_Deployed(
            "access-control", "lens.access-control.owner-admin", "access-control", "lens.access-control.owner-admin"
        );
    }
}
