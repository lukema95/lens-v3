// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Account} from "./../primitives/account/Account.sol";

contract AccountFactory {
    event Lens_AccountFactory_Deployment(
        address indexed account,
        address indexed owner,
        string metadataURI,
        address[] accountManagers,
        uint256[][] executionRoles,
        uint256[][] primitiveRoles
    );

    function deployAccount(
        address owner,
        string calldata metadataURI,
        address[] calldata accountManagers,
        uint256[][] memory executionRoles,
        uint256[][] memory primitiveRoles
    ) external returns (address) {
        // TODO: Make it a proxy
        Account account = new Account(owner, metadataURI, accountManagers, executionRoles, primitiveRoles);
        emit Lens_AccountFactory_Deployment(
            address(account), owner, metadataURI, accountManagers, executionRoles, primitiveRoles
        );
        return address(account);
    }
}
