// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Username_Paid {
    UsernameCore _usernameCore;

    function registerUsername(string memory username, bytes calldata data) external {
        // charge msg.sender
        UsernameCore(_usernameCore).delegateCall(_registerUsername(msg.sender, username, data));
    }

    function unregisterUsername(string memory username, bytes calldata data) external {
        if (_usernameCore.userOf(username) != msg.sender) {
            revert(); // TODO: This could be on the core too, idk
        }
        UsernameCore(_usernameCore).delegateCall(_unregisterUsername(username, data));
    }

    function nameOf(address user) external view returns (string memory) {
        return StorageLib.nameOf(user);
    }

    function userOf(string memory name) external view returns (address) {
        return StorageLib.userOf(name);
    }
}

contract Username_App {
    address _appAdmin;
    UsernameCore _usernameCore;

    modifier onlyApp() {
        if (_appAdmin != msg.sender) {
            revert();
        }
        _;
    }

    // TODO: We need to pass account here, in other cases nope. Would be better to have an common interface.
    // Otherwise it breaks this idea of "you have a primitive interface and you can swap one flavor for another
    // at any time". It makes sense to change the inferface if it really changes the flavor so much that it could be
    // considered a different primitive (e.g. Multi-follow Graph vs Simple-Follow Graph)
    // but here it just changes a simple permission...
    function registerUsernameOnBehalf(address account, string memory username, bytes calldata data) external onlyApp {
        UsernameCore(_usernameCore).delegateCall(_registerUsername(account, username, data));
    }

    function unregisterUsernameOnBehalf(string memory username, bytes calldata data) external onlyApp {
        UsernameCore(_usernameCore).delegateCall(_unregisterUsername(username, data));
    }

    function nameOf(address user) external view returns (string memory) {
        return StorageLib.nameOf(user);
    }

    function userOf(string memory name) external view returns (address) {
        return StorageLib.userOf(name);
    }
}

library UsernameCore {
    string _namespace;

    mapping(string => address) private _nameToUser;
    mapping(address => string) private _userToName; // aka Reverse record

    event UsernameUnregistered(string username, address indexed previousAccount, bytes data);
    event UsernameRegistered(string username, address indexed account, bytes data);

    function $namespace() internal returns (string storage) {}

    function registerUsername(string memory username, bytes calldata data) external {
        _registerUsername(msg.sender, username, data);
    }

    function unregisterUsername(string memory username, bytes calldata data) external {
        _unregisterUsername(username, data);
    }

    function _registerUsername(address account, string memory username, bytes calldata data) internal {
        if (_nameToUser[username] != address(0)) {
            revert(); // Username already taken
        }
        _nameToUser[username] = account;
        _userToName[account] = username;
        emit UsernameRegistered(username, account, data);
    }

    function _unregisterUsername(string memory username, bytes calldata data) internal {
        address account = _nameToUser[username];
        if (account == address(0)) {
            revert(); // Username not registered
        }
        delete _userToName[account];
        delete _nameToUser[username];
        emit UsernameUnregistered(username, account, data);
    }
}
