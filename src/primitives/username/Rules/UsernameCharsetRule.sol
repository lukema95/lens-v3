// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccessControl} from './../../access-control/IAccessControl.sol';
import {IUsernameRules} from './../IUsernameRules.sol';

contract UsernameCharsetRule is IUsernameRules {
    struct Permissions {
        bool canSetRolePermissions;
        bool canSkipCharsetRestrictions;
    }

    struct Restrictions {
        bool allowNumeric;
        bool allowLatinLowercase;
        bool allowLatinUppercase;
        string customAllowedCharset; // Optional (pass empty string if not needed)
        string customDisallowedCharset; // Optional (pass empty string if not needed)
        string cannotStartWith; // Optional (pass empty string if not needed)
    }

    // TODO: This "_accessControl" address is not initliazed here because this is assumed being initialized in the combinator contract
    // and shared across all rules. We need to think about this, specially if this rule can be used standalone without a combinator too.
    //
    // But if somebody wants to have a specific per-rule accessControl - then they can use a local variable to store it.
    IAccessControl internal _accessControl; // "lens.username.accessControl"

    Restrictions internal _charsetRestrictions;

    mapping(uint256 => Permissions) _rolePermissions; // "lens.username.rules.UsernameLengthRule.rolePermissions"

    address immutable IMPLEMENTATION;

    constructor(IAccessControl accessControl) {
        IMPLEMENTATION = address(this);
        // Initialize the access control. If this will be used with a proxy, we suggest to pass address(0) in impl.
        _accessControl = accessControl;
    }

    /**
     * Option #1: It is used directly.
     *      - Access control set in the constructor.
     * Option #2: It is used with a UUPS, Transparent or Beacon proxy.
     *      - Access control set through initialize function.
     * Option #3: It is used with a combinator (which is like a proxy too).
     *      - Access control set in the combinator contract.
     */
    // We need this function for the Option #2: Proxy.
    function initiliaze(IAccessControl accessControl) external {
        // TODO: This should be read from the "lens.username.accessControl" slot
        require(address(_accessControl) == address(0), 'UsernameCharsetRule: Already initialized');
        _accessControl = accessControl;
    }

    function setRolePermissions(
        uint256 role,
        bool canSetRolePermissions, // TODO: Think about this better
        bool canSkipCharsetRestrictions
    ) external {
        require(_rolePermissions[_accessControl.getRole(msg.sender)].canSetRolePermissions); // Must have canSetRolePermissions
        _rolePermissions[role] = Permissions(canSetRolePermissions, canSkipCharsetRestrictions);
    }

    function configure(bytes calldata data) external override {
        require(address(this) != IMPLEMENTATION); // Cannot initialize implementation contract
        (
            Restrictions memory charsetRestrictions,
            uint256 ownerRoleId,
            bool canSetRolePermissions,
            bool canSkipCharsetRestrictions
        ) = abi.decode(data, (Restrictions, uint256, bool, bool));
        _charsetRestrictions = charsetRestrictions;
        _rolePermissions[ownerRoleId] = Permissions(canSetRolePermissions, canSkipCharsetRestrictions);
    }

    function processRegistering(
        address originalMsgSender,
        address,
        string memory username,
        bytes calldata
    ) external view override {
        if (_rolePermissions[_accessControl.getRole(originalMsgSender)].canSkipCharsetRestrictions) {
            return;
        }
        // Cannot start with a character in the cannotStartWith charset
        require(
            !_isInCharset(bytes(username)[0], _charsetRestrictions.cannotStartWith),
            'UsernameCharsetRule: Username cannot start with specified character'
        );
        // Check if the username contains only allowed characters
        for (uint256 i = 0; i < bytes(username).length; i++) {
            bytes1 char = bytes(username)[i];
            // Check disallowed chars first
            require(
                !_isInCharset(char, _charsetRestrictions.customDisallowedCharset),
                'UsernameCharsetRule: Username contains disallowed character'
            );

            // Check allowed charsets next
            if (_isNumeric(char)) {
                require(_charsetRestrictions.allowNumeric, 'UsernameCharsetRule: Username cannot contain numbers');
            } else if (_isLatinLowercase(char)) {
                require(
                    _charsetRestrictions.allowLatinLowercase,
                    'UsernameCharsetRule: Username cannot contain lowercase latin characters'
                );
            } else if (_isLatinUppercase(char)) {
                require(
                    _charsetRestrictions.allowLatinUppercase,
                    'UsernameCharsetRule: Username cannot contain uppercase latin characters'
                );
            } else if (bytes(_charsetRestrictions.customAllowedCharset).length > 0) {
                require(
                    _isInCharset(char, _charsetRestrictions.customAllowedCharset),
                    'UsernameCharsetRule: Username contains disallowed character'
                );
            } else {
                // If not in any of the above charsets, reject
                revert('UsernameCharsetRule: Username contains disallowed character');
            }
        }
    }

    function processUnregistering(address, address, string memory, bytes calldata) external pure override {}

    // Internal Charset Helper functions

    /// @dev We only accept lowercase characters to avoid confusion.
    /// @param char The character to check.
    /// @return True if the character is alphanumeric, false otherwise.
    function _isNumeric(bytes1 char) internal pure returns (bool) {
        return (char >= '0' && char <= '9');
    }

    /// @dev We only accept lowercase characters to avoid confusion.
    /// @param char The character to check.
    /// @return True if the character is alphanumeric, false otherwise.
    function _isLatinLowercase(bytes1 char) internal pure returns (bool) {
        return (char >= 'a' && char <= 'z');
    }

    /// @dev We only accept lowercase characters to avoid confusion.
    /// @param char The character to check.
    /// @return True if the character is alphanumeric, false otherwise.
    function _isLatinUppercase(bytes1 char) internal pure returns (bool) {
        return (char >= 'A' && char <= 'Z');
    }

    function _isInCharset(bytes1 char, string memory charset) internal pure returns (bool) {
        for (uint256 i = 0; i < bytes(charset).length; i++) {
            if (char == bytes1(bytes(charset)[i])) {
                return true;
            }
        }
        return false;
    }
}
