// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAccessControl {
    /**
     * Returns true if the account has granted access to the specified permission, false otherwise.
     * This function MUST NOT revert. Instead, return false.
     *
     * @param account The account to check if has access to a permission.
     * @param contractAddress The address where the permission is queried.
     * @param permissionId The ID of the permission.
     */
    function hasAccess(address account, address contractAddress, uint256 permissionId) external view returns (bool);
}
