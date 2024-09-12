// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ICommunity} from "./ICommunity.sol";
import {ICommunityRule} from "./ICommunityRule.sol";
import {CommunityCore as Core} from "./CommunityCore.sol";
import {IAccessControl} from "./../access-control/IAccessControl.sol";
import {AccessControlLib} from "./../libraries/AccessControlLib.sol";
import {DataElement} from "./../../types/Types.sol";

contract Community is ICommunity {
    using AccessControlLib for IAccessControl;
    using AccessControlLib for address;

    // Resource IDs involved in the contract
    uint256 constant SET_RULES_RID = uint256(keccak256("SET_RULES"));
    uint256 constant SET_METADATA_RID = uint256(keccak256("SET_METADATA"));
    uint256 constant SET_EXTRA_DATA_RID = uint256(keccak256("SET_EXTRA_DATA"));
    uint256 constant CHANGE_ACCESS_CONTROL_RID = uint256(keccak256("CHANGE_ACCESS_CONTROL"));

    constructor(string memory metadataURI, IAccessControl accessControl) {
        Core.$storage().metadataURI = metadataURI;
        Core.$storage().accessControl = address(accessControl);
        emit Lens_Community_MetadataUriSet(metadataURI);
    }

    // Access Controlled functions

    function setCommunityRules(ICommunityRule communityRules) external override {
        Core.$storage().accessControl.requireAccess(msg.sender, SET_RULES_RID);
        Core.$storage().communityRules = address(communityRules);
        emit Lens_Community_RulesSet(address(communityRules));
    }

    function setMetadataURI(string calldata metadataURI) external override {
        Core.$storage().accessControl.requireAccess(msg.sender, SET_METADATA_RID);
        Core.$storage().metadataURI = metadataURI;
        emit Lens_Community_MetadataUriSet(metadataURI);
    }

    // TODO: This is a 1-step operation, while some of our AC owner transfers are a 2-step, or even 3-step operations.
    function setAccessControl(IAccessControl accessControl) external {
        // msg.sender must have permissions to change access control
        Core.$storage().accessControl.requireAccess(msg.sender, CHANGE_ACCESS_CONTROL_RID);
        accessControl.verifyHasAccessFunction();
        Core.$storage().accessControl = address(accessControl);
    }

    function setExtraData(DataElement[] calldata extraDataToSet) external override {
        Core.$storage().accessControl.requireAccess(msg.sender, SET_EXTRA_DATA_RID);
        Core._setExtraData(extraDataToSet);
        for (uint256 i = 0; i < extraDataToSet.length; i++) {
            emit Lens_Community_ExtraDataSet(extraDataToSet[i].key, extraDataToSet[i].value, extraDataToSet[i].value);
        }
    }

    // Public functions

    function joinCommunity(address account, bytes calldata data) external override {
        require(msg.sender == account);
        ICommunityRule rules = ICommunityRule(Core.$storage().communityRules);
        if (address(rules) != address(0)) {
            rules.processJoining(msg.sender, account, data);
        }
        uint256 membershipId = Core._grantMembership(account);
        emit Lens_Community_MemberJoined(account, membershipId, data);
    }

    function leaveCommunity(address account, bytes calldata data) external override {
        require(msg.sender == account);
        ICommunityRule rules = ICommunityRule(Core.$storage().communityRules);
        if (address(rules) != address(0)) {
            rules.processLeaving(msg.sender, account, data);
        }
        uint256 membershipId = Core._revokeMembership(account);
        emit Lens_Community_MemberLeft(account, membershipId, data);
    }

    // TODO: Why don't we have addMember? Because we don't want to kidnap someone into the community?

    function removeMember(address account, bytes calldata data) external override {
        ICommunityRule rules = ICommunityRule(Core.$storage().communityRules);
        require(address(rules) != address(0), "Community: rules are required to remove members");
        rules.processRemoval(msg.sender, account, data);
        uint256 membershipId = Core._revokeMembership(account);
        emit Lens_Community_MemberRemoved(account, membershipId, data);
    }

    // Getters

    function getMetadataURI() external view override returns (string memory) {
        return Core.$storage().metadataURI;
    }

    function getNumberOfMembers() external view override returns (uint256) {
        return Core.$storage().numberOfMembers;
    }

    function getMembershipTimestamp(address account) external view override returns (uint256) {
        return Core.$storage().memberships[account].timestamp;
    }

    function getMembershipId(address account) external view override returns (uint256) {
        return Core.$storage().memberships[account].id;
    }

    function getCommunityRules() external view override returns (address) {
        return Core.$storage().communityRules;
    }

    function getAccessControl() external view override returns (address) {
        return Core.$storage().accessControl;
    }

    function getExtraData(bytes32 key) external view override returns (bytes memory) {
        return Core.$storage().extraData[key];
    }
}
