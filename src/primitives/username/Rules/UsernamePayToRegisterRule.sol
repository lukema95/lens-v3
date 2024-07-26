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

    IAccessControl internal _accessControl; // "lens.username.accessControl"

    // TODO: We can think and choose proper values for this ResourceID, like "lens.skip_payment.permission" or "lens.usernames.rules.can_skip_payment.permission" or whatever, depending how global/local we want it
    uint256 constant SKIP_PAYMENT_RID = uint256(keccak256('SKIP_PAYMENT'));
    uint256 constant CHANGE_RULE_ACCESS_CONTROL_RID = uint256(keccak256('CHANGE_RULE_ACCESS_CONTROL'));

    address immutable IMPLEMENTATION;

    constructor() {
        IMPLEMENTATION = address(this);
    }

    function configure(bytes calldata data) external override {
        require(address(this) != IMPLEMENTATION); // Cannot initialize implementation contract
        // TODO: Who can run configure?
        (address token, uint256 price, address accessControl) = abi.decode(data, (address, uint256, address));
        _token = token;
        _price = price;
        if (accessControl != address(_accessControl)) {
            require(
                _accessControl.hasAccess({
                    account: msg.sender,
                    resourceLocation: address(this),
                    resourceId: CHANGE_RULE_ACCESS_CONTROL_RID
                }),
                'UsernamePayToRegisterRule: access denied'
            );
            _accessControl = IAccessControl(accessControl);
        }
    }

    function processRegistering(
        address originalMsgSender,
        address account,
        string memory,
        bytes calldata
    ) external override {
        if (
            _accessControl.hasAccess({
                account: originalMsgSender,
                resourceLocation: address(this),
                resourceId: SKIP_PAYMENT_RID
            })
        ) {
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
