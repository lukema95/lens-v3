// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Account, AccountManagerPermissions} from "./../primitives/account/Account.sol";
import {SourceStamp} from "./../types/Types.sol";

contract AccountFactory {
    event Lens_AccountFactory_Deployment(
        address indexed account,
        address indexed owner,
        string metadataURI,
        address metadataURISource,
        address[] accountManagers,
        AccountManagerPermissions[] accountManagersPermissions
    );

    function deployAccount(
        address owner,
        string calldata metadataURI,
        SourceStamp calldata metadataURISourceStamp,
        address[] calldata accountManagers,
        AccountManagerPermissions[] calldata accountManagersPermissions
    ) external returns (address) {
        // TODO: Make it a proxy
        Account account =
            new Account(owner, metadataURI, metadataURISourceStamp, accountManagers, accountManagersPermissions);
        emit Lens_AccountFactory_Deployment(
            address(account),
            owner,
            metadataURI,
            metadataURISourceStamp.source,
            accountManagers,
            accountManagersPermissions
        );
        return address(account);
    }
}
