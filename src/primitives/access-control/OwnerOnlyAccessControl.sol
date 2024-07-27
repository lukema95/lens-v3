// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccessControl} from './IAccessControl.sol';
import {Ownership} from './../../diamond/Ownership.sol';

contract OwnerOnlyAccessControl is Ownership, IAccessControl {
    constructor(address owner) Ownership(owner) {}

    function hasAccess(
        address account,
        address /* resourceLocation */,
        uint256 /* resourceId */
    ) external view override returns (bool) {
        return account == _owner;
    }
}
