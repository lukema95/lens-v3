// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {AccountManagerPermissions} from "./Account.sol";
import {SourceStamp} from "./../../types/Types.sol";

interface IAccount {
    event Lens_Account_MetadataURISet(string metadataURI, address indexed source);
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
    function setMetadataURI(string calldata _metadataURI, SourceStamp calldata sourceStamp) external;
    function executeTransaction(address to, uint256 value, bytes calldata data) external payable;
    function getMetadataURI(address source) external view returns (string memory);

    receive() external payable;
}
