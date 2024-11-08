// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

struct AccountManagerPermissions {
    bool canExecuteTansactions;
    bool canTransferTokens;
    bool canTransferNative;
    bool canSetMetadataURI;
}

interface IAccount {
    event Lens_Account_MetadataURISet(string metadataURI);
    event Lens_Account_OwnerTransferred(address indexed newOwner);
    event Lens_Account_TransactionExecuted(address indexed to, uint256 value, bytes data, address indexed executor);
    event Lens_Account_AccountManagerAdded(address accountManager, AccountManagerPermissions permissions);
    event Lens_Account_AccountManagerRemoved(address accountManager);
    event Lens_Account_AccountManagerUpdated(address accountManager, AccountManagerPermissions permissions);
    event Lens_Account_AllowNonOwnerSpending(bool allow, uint256 timestamp);

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
