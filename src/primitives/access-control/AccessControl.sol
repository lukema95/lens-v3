// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccessControl} from './IAccessControl.sol';

contract AccessControl is IAccessControl {
    struct Permissions {
        bool canGrant;
        bool canRevoke;
    }

    address public _owner;

    mapping(address => bytes32) public _roles;

    mapping(bytes32 => mapping(bytes32 => Permissions)) public _rolePermissions;

    constructor(address owner) {
        _owner = owner;
        _roles[owner] = keccak256('OWNER');
    }

    function setRole(address account, uint256 roleId) external override {
        // if (role == keccak256('OWNER')) {
        //     require(msg.sender == _owner);
        //     // transfer ownership - here you start the 2-step secure transfer process
        // }
        // bytes32 accountRole = _roles[account];
        // bytes32 msgSenderRole = _roles[msg.sender];
        // require(_rolePermissions[msgSenderRole][accountRole].canRevoke); // But this is tricky, because you might be revoking "MODERATOR" role to grant "ADMIN" role. So that is ok... but what if you are revoking "ADMIN" role to grant "MODERATOR" role? That should be prevented if you are not OWNER.
        // require(_rolePermissions[msgSenderRole][role].canGrant);
    }

    function hasRole(address account, uint256 roleId) external view override returns (bool) {}

    function getRole(address account) external view override returns (uint256) {}
}
