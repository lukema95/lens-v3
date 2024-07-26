// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccessControl} from './IAccessControl.sol';

contract AddressBasedAccessControl is IAccessControl {
    // TODO: It can implement the role-based, and make each role an address, but can also just implement the plain IAccessControl directly

    // function hasRole(address account, uint256 roleId) external pure override returns (bool) {
    //     return roleId == uint256(uint160(account));
    // }

    // function getRole(address account) external pure override returns (uint256) {
    //     return uint256(uint160(account));
    // }

    // function setRole(address account, uint256 roleId) external pure override {
    //     require(roleId == uint256(uint160(account)));
    // }

    function hasAccess(
        address account,
        address resourceLocation,
        uint256 resourceId,
        bytes calldata data
    ) external view override returns (bool) {}
}
