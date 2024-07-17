// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAccessControl {
    function setRole(address account, uint256 roleId) external;

    function hasRole(address account, uint256 roleId) external view returns (bool);

    function getRole(address account) external view returns (uint256);
}
