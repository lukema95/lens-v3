// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Access} from "./../access-control/IRoleBasedAccessControl.sol";

interface IAccount {
    event Lens_Account_AccountManagerAdded(address indexed accountManager);
    event Lens_Account_AccountManagerRemoved(address indexed accountManager);
    event Lens_Account_MetadataURISet(string metadataURI);
    event Lens_Account_OwnerTransferred(address indexed newOwner);
    event TransactionExecuted(address indexed to, uint256 value, bytes data, address indexed executor);
    // TODO: Move events from the primitive here

    function addAccountManager(
        address _accountManager,
        uint256[] calldata executionRoles,
        uint256[] calldata primitiveRoles
    ) external;
    function removeAccountManager(address _accountManager) external;
    function addAccountManagerRoles(
        address _accountManager,
        uint256[] calldata executionRoles,
        uint256[] calldata primitiveRoles
    ) external;
    function removeAccountManagerRoles(
        address _accountManager,
        uint256[] calldata executionRoles,
        uint256[] calldata primitiveRoles
    ) external;
    function defineExecutionRolePermissions(
        uint256 roleId,
        address[] calldata contractAddresses,
        uint256[] calldata permissionIds,
        Access[] calldata accesses
    ) external;
    function definePrimitiveRolePermissions(
        uint256 roleId,
        uint256[] calldata permissionIds,
        Access[] calldata accesses
    ) external;
    function setMetadataURI(string calldata _metadataURI) external;
    function executeTransaction(address to, uint256 value, bytes calldata data) external payable;

    receive() external payable;
}
