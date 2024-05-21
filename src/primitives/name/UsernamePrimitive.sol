// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UsernamePrimitive {
    mapping(string => address) private _nameToUser;
    mapping(address => string) private _userToName;

    event UsernameRegistered(string username, address indexed userAddress);
    event UsernameUpdated(string username, address indexed userAddress);

    function registerUsername(string memory username) external {
        // Check if username is already taken and its charset.
        _nameToUser[username] = msg.sender;
        _userToName[msg.sender] = username;
        emit UsernameRegistered(username, msg.sender);
    }

    // Removing it, updating it, etc.

    function nameOf(address user) external view returns (string memory) {
        return _userToName[user];
    }

    function userOf(string memory name) external view returns (address) {
        return _nameToUser[name];
    }
}
