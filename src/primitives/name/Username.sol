// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IUsernameModule} from './IUsernameModule.sol';

// TODO: Kinda bad on consistency that we have "user" here but "account" in the other primitive.
contract Username {
    address _admin;
    string _namespace;

    IUsernameModule _module;

    mapping(string => address) private _nameToUser;
    mapping(address => string) private _userToName; // aka Reverse record

    event UsernameRegistered(string username, address indexed userAddress, bytes data);
    event UsernameUpdated(string username, address indexed userAddress, bytes data);

    constructor(string memory namespace) {
        _namespace = namespace;
    }

    function setModule(IUsernameModule module, bytes calldata data) external {
        if (_admin != msg.sender) {
            revert();
        }
        _module = module;
        module.initialize(data);
    }

    // TODO: Do we allow addresses that have registering/unregistering permissions? Probably YES!

    function registerUsername(string memory username, bytes calldata data) external {
        if (_nameToUser[username] != address(0)) {
            revert(); // Username already taken
        }
        // Check if username is already taken and its charset.
        _nameToUser[username] = msg.sender;
        _userToName[msg.sender] = username;
        _module.processRegistering(msg.sender, username, data);
        emit UsernameRegistered(username, msg.sender, data);
    }

    // Removing it, updating it, etc.

    /*

        MultiModuleModule:
         - NFT Tokenizer (mint(), burn(), ERC-721 ones, etc)
         - TwitterMigrator (migrateFromX())
         - PayByChar (usual processRegister())
         - AZValidator

         Will this MultiModuleModule be an entry point?
         If yes - how?

         Diamond? With fallback trying to go to the right module?

    */

    //////////////////////////////////////

    // Getters

    function nameOf(address user) external view returns (string memory) {
        return _userToName[user];
    }

    function userOf(string memory name) external view returns (address) {
        return _nameToUser[name];
    }
}
