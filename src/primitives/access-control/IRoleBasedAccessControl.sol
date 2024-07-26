// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccessControl} from './IAccessControl.sol';

// TODO: Should we add `bytes data` param to the `hasAccess`? For more complex logic like providing admin signatures.
interface IRoleBasedAccessControl is IAccessControl {
    enum AccessPermission {
        UNDEFINED,
        GRANTED,
        DENIED
    }

    // Role-flavored function to query access
    function hasAccess(uint256 roleId, address resourceLocation, uint256 resourceId) external view returns (bool);

    // Role functions
    function setRole(address account, uint256 roleId, bytes calldata data) external;

    function hasRole(address account, uint256 roleId) external view returns (bool);

    function getRole(address account) external view returns (uint256);

    // Resource access permissions functions - Global
    function setGlobalAccess(
        uint256 roleId,
        uint256 resourceId,
        AccessPermission accessPermission,
        bytes calldata data
    ) external;

    // Resource access permissions functions - Scoped (location is address based)
    function setScopedAccess(
        uint256 roleId,
        address resourceLocation,
        uint256 resourceId,
        AccessPermission accessPermission,
        bytes calldata data
    ) external;

    // These are not meant to be used to check access, but to query internal configuration state instead.
    function getGlobalAccess(uint256 roleId, uint256 resourceId) external view returns (AccessPermission);

    function getGlobalAccess(address account, uint256 resourceId) external view returns (AccessPermission);

    function getScopedAccess(
        uint256 roleId,
        address resourceLocation,
        uint256 resourceId
    ) external view returns (AccessPermission);

    function getScopedAccess(
        address account,
        address resourceLocation,
        uint256 resourceId
    ) external view returns (AccessPermission);
}
