// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {AccountManagerPermissions} from "./Account.sol";

interface IAccount {
    event Lens_Account_MetadataURISet(string metadataURI);
    event Lens_Account_OwnerTransferred(address indexed newOwner);
    event TransactionExecuted(address indexed to, uint256 value, bytes data, address indexed executor);
    // TODO: Move events from the primitive here

    function addAccountManager(address _accountManager, AccountManagerPermissions calldata accountManagerPermissions)
        external;
    function removeAccountManager(address _accountManager) external;
    function updateAccountManagerPermissions(
        address accountManager,
        AccountManagerPermissions calldata accountManagerPermissions
    ) external;
    function setMetadataURI(string calldata _metadataURI) external;
    function executeTransaction(address to, uint256 value, bytes calldata data) external payable;

    receive() external payable;
}
