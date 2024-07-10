// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICommunityRules {
    function processJoining(address sender, address account) external;

    function processLeave(address sender, address account) external;
}

// Base Abstract Core code, unusable on its own
abstract contract CommunityPrimitive {
    ICommunityRules internal _communityRules;

    function _joinCommunity(address account, bool skipAccountAsSenderCheck, bool skipRulesCheck) internal {
        if (!skipAccountAsSenderCheck && msg.sender != account) {
            revert();
        }
        // >>>> Core Join Community Code goes here <<<<
        if (!skipRulesCheck) {
            _communityRules.processJoining(msg.sender, account);
        }
    }

    function _leaveCommunity(address account, bool skipAccountAsSenderCheck, bool skipRulesCheck) internal {
        if (!skipAccountAsSenderCheck && msg.sender != account) {
            revert();
        }
        // >>>> Core Join Community Code goes here <<<<
        if (!skipRulesCheck) {
            _communityRules.processLeave(msg.sender, account);
        }
    }
}

// Simple Community contract with a public facing joinCommunity function
contract SimpleCommunity is CommunityPrimitive {
    function joinCommunity(address account) external {
        _joinCommunity(account, false, false);
    }

    function leaveCommunity(address account) external {
        _leaveCommunity(account, false, false);
    }
}

// If you want to add two extensions - you need to create a new contract
contract TokenizeAndAdminCommunity is CommunityPrimitive {
    mapping(uint256 tokenId => address owner) private _tokenOwners;

    function joinCommunity(address account) external {
        _joinCommunity(account, false, false);
    }

    function leaveCommunity(address account) public {
        _leaveCommunity(account, false, false);
    }

    function adminAddToCommunity(address account) external {
        _joinCommunity(account, true, true);
    }

    function adminRemoveFromCommunity(address account) external {
        _leaveCommunity(account, true, true);
    }

    function burn(uint256 tokenId) external {
        if (msg.sender != ownerOf(tokenId)) {
            revert();
        }
        _leaveCommunity(msg.sender, true, true);
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        return _tokenOwners[tokenId];
    }
}
