// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAccessControl {
    // TODO: Does the `hasAccess` should be a non-view function, so it can change internal state if required?
    // e.g. you allow access for a single time, so after queried it gets "expired/revoked" immediatly

    /**
     * Returns true if the account has access to the specified resource, false otherwise.
     * This function MUST NOT revert. Instead, return false.
     *
     * @param account The account to check if has access to a resource.
     * @param resourceLocation The address where the resource is located.
     * @param resourceId The ID of the resource.
     */
    function hasAccess(address account, address resourceLocation, uint256 resourceId) external view returns (bool);
}
