// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ICommunityRule} from "./ICommunityRule.sol";
import {DataElement} from "./../../types/Types.sol";

interface ICommunity {
    event Lens_Community_MetadataUriSet(string metadataURI);

    event Lens_Community_RulesSet(address indexed communityRules);

    event Lens_Community_MemberJoined(address indexed account, uint256 indexed memberId, bytes data);

    event Lens_Community_MemberLeft(address indexed account, uint256 indexed memberId, bytes data);

    event Lens_Community_MemberRemoved(address indexed account, uint256 indexed memberId, bytes data);

    event Lens_Community_ExtraDataSet(bytes32 indexed key, bytes value, bytes indexed valueIndexed);

    function setCommunityRules(ICommunityRule communityRules) external;

    function setMetadataURI(string calldata metadataURI) external;

    function setExtraData(DataElement[] calldata extraDataToSet) external;

    function joinCommunity(address account, bytes calldata data) external;

    function leaveCommunity(address account, bytes calldata data) external;

    function removeMember(address account, bytes calldata data) external;

    function getMetadataURI() external view returns (string memory);

    function getNumberOfMembers() external view returns (uint256);

    function getMembershipTimestamp(address account) external view returns (uint256);

    function getMembershipId(address account) external view returns (uint256);

    function getCommunityRules() external view returns (address);

    function getAccessControl() external view returns (address);

    function getExtraData(bytes32 key) external view returns (bytes memory);
}
