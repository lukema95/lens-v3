// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library Events {
    event Lens_Contract_Deployed(
        string indexed indexedContractType, string indexed indexedFlavour, string contractType, string flavour
    );

    event Lens_PermissionId_Available(uint256 indexed permissionId, string name);
}
