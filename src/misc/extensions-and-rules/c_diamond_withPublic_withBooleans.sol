// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICommunityRules {
    function processJoining(address sender, address account) external;

    function processLeave(address sender, address account) external;
}

// Base Primitive code
contract CommunityPrimitive {
    ICommunityRules internal _communityRules;

    // This function is diamond facet facing public
    function joinCommunity(address account) external {
        _joinCommunity(account, false, false);
    }

    // This function is diamond facet facing public
    function leaveCommunity(address account) external {
        _leaveCommunity(account, false, false);
    }

    // This function is not added to diamond facets and is "internal"
    function _joinCommunity(address account, bool skipAccountAsSenderCheck, bool skipRulesCheck) public {
        if (!skipAccountAsSenderCheck && msg.sender != account) {
            revert();
        }
        // >>>> Core Join Community Code goes here <<<<
        if (!skipRulesCheck) {
            _communityRules.processJoining(msg.sender, account);
        }
    }

    // This function is not added to diamond facets and is "internal"
    function _leaveCommunity(address account, bool skipAccountAsSenderCheck, bool skipRulesCheck) public {
        if (!skipAccountAsSenderCheck && msg.sender != account) {
            revert();
        }
        // >>>> Core Leave Community Code goes here <<<<
        if (!skipRulesCheck) {
            _communityRules.processLeave(msg.sender, account);
        }
    }
}

// If you want to add two extensions - you need to create a new contract
contract TokenizedCommunityFacet {
    mapping(uint256 tokenId => address owner) private _tokenOwners;

    address PRIMITIVE = address(0x123); // the main CommunityPrimitive implementation address

    function burn(uint256 tokenId) external {
        if (msg.sender != ownerOf(tokenId)) {
            revert();
        }

        (bool success, ) = PRIMITIVE.delegatecall(
            abi.encodeWithSignature('_leaveCommunity(address,bool,bool)', msg.sender, true, true)
        );

        require(success, 'leaving community failed');
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        return _tokenOwners[tokenId];
    }
}

contract AdminCommunityFacet {
    address ADMIN;

    function adminAddToCommunity(address account) external {
        if (msg.sender != ADMIN) {
            revert();
        }
        abi.encodeWithSignature('_joinCommunity(address,bool,bool)', msg.sender, true, true)
    }

    function adminRemoveFromCommunity(address account) external {
        if (msg.sender != ADMIN) {
            revert();
        }
        abi.encodeWithSignature('_leaveCommunity(address,bool,bool)', msg.sender, true, true)
    }
}
