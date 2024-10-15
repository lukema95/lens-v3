// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Ownership} from "./../../diamond/Ownership.sol";
import {IRoleBasedAccessControl} from "./IRoleBasedAccessControl.sol";
import {Events} from "./../../types/Events.sol";

contract AddressBasedAccessControl is Ownership, IRoleBasedAccessControl {
    mapping(address => mapping(uint256 => Access)) internal _globalAccess;
    mapping(address => mapping(address => mapping(uint256 => Access))) internal _scopedAccess;

    constructor(address owner) Ownership(owner) {
        emit Events.Lens_Contract_Deployed(
            "access-control", "lens.access-control.address-based", "access-control", "lens.access-control.address-based"
        );
    }

    function hasAccess(address account, address contractAddress, uint256 permissionId)
        external
        view
        override
        returns (bool)
    {
        // `_getScopedAccess` always returns Access.GRANTED for `_owner`.
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

    function grantRole(address account, uint256 roleId) external pure override {
        // Roles are already pre-assigned. Reverts on every attempt except when it matches the already assigned role.
        require(roleId == _addressToRoleId(account));
    }

    function revokeRole(address, /* account */ uint256 /* roleId */ ) external pure override {
        revert();
    }

    function hasRole(address account, uint256 roleId) external pure override returns (bool) {
        return roleId == _addressToRoleId(account);
    }

    // Note: We allow to deny access to current owner. It will not change the access while it is still the owner,
    // but it will impact right after transferring the ownership.
    function setGlobalAccess(uint256 roleId, uint256 permissionId, Access access, bytes calldata /* data */ )
        external
        override
        onlyOwner
    {
        require(_isValidRoleId(roleId), "Invalid roleId");
        _globalAccess[_roleIdToAddress(roleId)][permissionId] = access;
    }

    // Note: We allow to deny access to current owner. It will not change the access while it is still the owner,
    // but it will impact right after transferring the ownership.
    function setScopedAccess(
        uint256 roleId,
        address contractAddress,
        uint256 permissionId,
        Access access,
        bytes calldata /* data */
    ) external override onlyOwner {
        require(_isValidRoleId(roleId), "Invalid roleId");
        _scopedAccess[_roleIdToAddress(roleId)][contractAddress][permissionId] = access;
    }

    function getGlobalAccess(uint256 roleId, uint256 permissionId) external view override returns (Access) {
        if (!_isValidRoleId(roleId)) {
            return Access.UNDEFINED;
        }
        return _getGlobalAccess(_roleIdToAddress(roleId), permissionId);
    }

    function getGlobalAccess(address account, uint256 permissionId) external view override returns (Access) {
        return _getGlobalAccess(account, permissionId);
    }

    function getScopedAccess(uint256 roleId, address contractAddress, uint256 permissionId)
        external
        view
        override
        returns (Access)
    {
        if (!_isValidRoleId(roleId)) {
            return Access.UNDEFINED;
        }
        return _getScopedAccess(_roleIdToAddress(roleId), contractAddress, permissionId);
    }

    function getScopedAccess(address account, address contractAddress, uint256 permissionId)
        external
        view
        override
        returns (Access)
    {
        return _getScopedAccess(account, contractAddress, permissionId);
    }

    function _getGlobalAccess(address account, uint256 permissionId) internal view returns (Access) {
        if (_owner == account) {
            return Access.GRANTED;
        } else {
            return _globalAccess[account][permissionId];
        }
    }

    function _getScopedAccess(address account, address contractAddress, uint256 permissionId)
        internal
        view
        returns (Access)
    {
        if (_owner == account) {
            return Access.GRANTED;
        } else {
            return _scopedAccess[account][contractAddress][permissionId];
        }
    }

    function _addressToRoleId(address account) internal pure returns (uint256) {
        return uint256(uint160(account));
    }

    function _roleIdToAddress(uint256 roleId) internal pure returns (address) {
        require(_isValidRoleId(roleId), "Invalid roleId");
        return address(uint160(roleId));
    }

    function _isValidRoleId(uint256 roleId) internal pure returns (bool) {
        // In this implementation roles are address-based, so the biggest possible roleId is the maximum uint160 value.
        return roleId <= type(uint160).max;
    }
}
