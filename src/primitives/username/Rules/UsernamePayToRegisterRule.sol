// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccessControl} from './../../access-control/IAccessControl.sol';
import {IUsernameRules} from './../IUsernameRules.sol';

// TODO: Replace this with an actual import if needed
interface IERC20 {
    function safeTransferFrom(address from, address to, uint256 value) external returns (bool);
}

contract UsernamePayToRegisterRule is IUsernameRules {
    address _token; // "lens.username.rules.UsernamePayToRegisterRule.token"
    uint256 _price; // "lens.username.rules.UsernamePayToRegisterRule.price"

    // TODO: This "_accessControl" address is not initliazed here because this is assumed being initialized in the combinator contract
    // and shared across all rules. We need to think about this, specially if this rule can be used standalone without a combinator too.
    //
    // But if somebody wants to have a specific per-rule accessControl - then they can use a local variable to store it.
    IAccessControl internal _accessControl; // "lens.username.accessControl"

    struct Permissions {
        bool canSetRolePermissions;
        bool canSkipPayment;
    }

    mapping(uint256 => Permissions) _rolePermissions; // "lens.username.rules.UsernamePayToRegisterRule.rolePermissions"

    address immutable IMPLEMENTATION;

    constructor() {
        IMPLEMENTATION = address(this);
    }

    function setRolePermissions(uint256 role, bool canSetRolePermissions, bool canSkipPayment) external {
        require(_rolePermissions[_accessControl.getRole(msg.sender)].canSetRolePermissions); // Must have canSetRolePermissions
        _rolePermissions[role] = Permissions(canSetRolePermissions, canSkipPayment);
    }

    function configure(bytes calldata data) external override {
        require(address(this) != IMPLEMENTATION); // Cannot initialize implementation contract
        (address token, uint256 price, uint256 ownerRoleId, bool canSetRolePermissions, bool canSkipPayment) = abi
            .decode(data, (address, uint256, uint256, bool, bool));
        _token = token;
        _price = price;
        _rolePermissions[ownerRoleId] = Permissions(canSetRolePermissions, canSkipPayment);
    }

    function processRegistering(
        address originalMsgSender,
        address account,
        string memory,
        bytes calldata
    ) external override {
        if (_rolePermissions[_accessControl.getRole(originalMsgSender)].canSkipPayment) {
            return;
        }
        require(
            IERC20(_token).safeTransferFrom(account, address(this), _price),
            'UsernamePayToRegisterRule: transfer failed'
        );
    }

    function processUnregistering(address, address, string memory, bytes calldata) external pure override {
        return;
    }
}
