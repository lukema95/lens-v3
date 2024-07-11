// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ICommunity} from './ICommunity.sol';
import {ICommunityRules} from './ICommunityRules.sol';
import {CommunityCore as Core} from './CommunityCore.sol';

contract Community is ICommunity {
    constructor(string memory metadataURI, address owner) {
        Core.$storage().metadataURI = metadataURI;
        Core.$storage().owner = owner;
    }

    // Owner functions

    function setCommunityRules(address communityRules, bytes calldata initializationData) external {
        require(msg.sender == Core.$storage().owner); // msg.sender must be owner
        Core.$storage().communityRules = communityRules;
        if (communityRules != address(0)) {
            ICommunityRules(communityRules).initialize(initializationData);
        }
        emit Lens_Community_RulesSet(communityRules, initializationData);
    }

    function setMetadataURI(string calldata metadataURI) external {
        require(msg.sender == Core.$storage().owner); // msg.sender must be owner
        Core.$storage().metadataURI = metadataURI;
        emit Lens_Community_MetadataUriSet(metadataURI);
    }

    // Public functions

    function joinCommunity(address account, bytes calldata data) external {
        require(msg.sender == account); // msg.sender must be the account
        ICommunityRules(Core.$storage().communityRules).processJoining(msg.sender, account, data);
        uint256 membershipId = Core.grantMembership(account);
        emit Lens_Community_MemberJoined(account, membershipId, data);
    }

    function leaveCommunity(address account, bytes calldata data) external {
        require(msg.sender == account); // msg.sender must be the account
        ICommunityRules(Core.$storage().communityRules).processLeaving(msg.sender, account, data);
        uint256 membershipId = Core.revokeMembership(account);
        emit Lens_Community_MemberLeft(account, membershipId, data);
    }

    function removeMember(address account, bytes calldata data) external {
        ICommunityRules(Core.$storage().communityRules).processRemoval(msg.sender, account, data);
        uint256 membershipId = Core.revokeMembership(account);
        emit Lens_Community_MemberRemoved(account, membershipId, data);
    }

    // Getters

    function getMetadataURI() external view returns (string memory) {
        return Core.$storage().metadataURI;
    }

    function getNumberOfMembers() external view returns (uint256) {
        return Core.$storage().numberOfMembers;
    }

    function getMembershipTimestamp(address account) external view returns (uint256) {
        return Core.$storage().memberships[account].timestamp;
    }

    function getMembershipId(address account) external view returns (uint256) {
        return Core.$storage().memberships[account].id;
    }

    function getCommunityRules() external view returns (address) {
        return Core.$storage().communityRules;
    }

    function getOwner() external view returns (address) {
        return Core.$storage().owner;
    }
}
