// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IOwnership {
    function getOwner() external view returns (address);
}
