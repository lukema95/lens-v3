// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICommunityRules {
    function processJoining(address sender, address account) external;

    function processLeave(address sender, address account) external;
}

// Base CommunityPrimitive code, unusable on its own
contract CommunityPrimitive {
    ICommunityRules internal _communityRules;

    function joinCommunity(address account) external {
        if (msg.sender != account) {
            revert();
        }
        // >>>> Core Join Community Code goes here <<<<
        _communityRules.processJoining(msg.sender, account);
    }

    function leaveCommunity(address account) external {
        if (msg.sender != account) {
            revert();
        }
        // >>>> Core Join Community Code goes here <<<<
        _communityRules.processLeave(msg.sender, account);
    }
}

// If you want to add two extensions:
// You need to create a new contract from scratch and Ctrl+C + Ctrl+V the code
contract TokenizeAndAdminCommunity {
    ICommunityRules internal _communityRules;
    mapping(uint256 tokenId => address owner) private _tokenOwners;
    address ADMIN;

    function joinCommunity(address account) external {
        if (msg.sender != account) {
            revert();
        }
        // >>>> Core Join Community Code goes here <<<<
        _communityRules.processJoining(msg.sender, account);
    }

    function leaveCommunity(address account) external {
        if (msg.sender != account) {
            revert();
        }
        // >>>> Core Join Community Code goes here <<<<
        _communityRules.processLeave(msg.sender, account);
    }

    function adminAddToCommunity(address account) external {
        if (msg.sender != ADMIN) {
            revert();
        }
        // >>>> Core Join Community Code goes here <<<<
    }

    function adminRemoveFromCommunity(address account) external {
        if (msg.sender != ADMIN) {
            revert();
        }
        // >>>> Core Join Community Code goes here <<<<
    }

    function burn(uint256 tokenId) external {
        if (msg.sender != ownerOf(tokenId)) {
            revert();
        }
        // >>>> Core Join Community Code goes here <<<<
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        return _tokenOwners[tokenId];
    }
}
