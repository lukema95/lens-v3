// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IUsernameRules} from './IUsernameRules.sol';

contract Username {
    address _admin;
    string _namespace;

    // TODO #1: Implement proper ownable pattern
    // TODO #2: Implement diamond storage
    // TODO #3: Implement in a way that allow extensions (taking into account we decided to use Diamond)
    //// TODO #4: Sample rules to Implement:
    /////////// - TwitterMigrator (migrateFromX())
    /////////// - PayByChar (usual processRegister())
    /////////// - AZValidator
    //// TODO #5: Sample extensions to Implement:
    /////////// - NFT Tokenizer (mint(), burn(), etc)

    IUsernameRules _usernameRules;

    mapping(string => address) private _nameToUser;
    mapping(address => string) private _userToName; // aka Reverse record

    event UsernameUnregistered(string username, address indexed previousAccount, bytes data);
    event UsernameRegistered(string username, address indexed account, bytes data);

    constructor(string memory namespace) {
        _namespace = namespace;
    }

    function setUsernameRules(IUsernameRules usernameRules, bytes calldata initializationData) external {
        if (_admin != msg.sender) {
            revert();
        }
        _usernameRules = usernameRules;
        if (address(usernameRules) != address(0)) {
            usernameRules.initialize(initializationData);
        }
    }

    function registerUsername(string memory username, bytes calldata data) external {
        if (_nameToUser[username] != address(0)) {
            revert(); // Username already taken
        }
        _nameToUser[username] = msg.sender;
        _userToName[msg.sender] = username;
        _usernameRules.processRegistering(msg.sender, username, data);
        emit UsernameRegistered(username, msg.sender, data);
    }

    function unregisterUsername(string memory username, bytes calldata data) external {
        if (_nameToUser[username] != msg.sender) {
            revert(); // Not your username
        }
        delete _nameToUser[username];
        delete _userToName[msg.sender];
        _usernameRules.processUnregistering(msg.sender, username, data);
        emit UsernameUnregistered(username, msg.sender, data);
    }

    // Getters

    function nameOf(address user) external view returns (string memory) {
        return _userToName[user];
    }

    function userOf(string memory name) external view returns (address) {
        return _nameToUser[name];
    }
}
