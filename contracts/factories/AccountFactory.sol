// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Account, AccountManagerPermissions} from "./../primitives/account/Account.sol";

contract AccountFactory {
    event Lens_AccountFactory_Deployment(
        address indexed account,
        address indexed owner,
        string metadataURI,
        address[] accountManagers,
        AccountManagerPermissions[] accountManagersPermissions
    );

    function deployAccount(
        address owner,
        string calldata metadataURI,
        address[] calldata accountManagers,
        AccountManagerPermissions[] calldata accountManagersPermissions
    ) external returns (address) {
        // TODO: Make it a proxy
        Account account = new Account(owner, metadataURI, accountManagers, accountManagersPermissions);
        emit Lens_AccountFactory_Deployment(
            address(account), owner, metadataURI, accountManagers, accountManagersPermissions
        );
        return address(account);
    }
}
