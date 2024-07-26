// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUsername {
    // event Lens_Username_RulesSet(address usernameRules, bytes initializationData);

    event Lens_Username_RulesSet(address usernameRules);

    event Lens_Username_Registered(string username, address indexed account, bytes data);

    event Lens_Username_Unregistered(string username, address indexed previousAccount, bytes data);

    // function setUsernameRules(address usernameRules, bytes calldata initializationData) external;

    function setUsernameRules(address usernameRules) external;

    function registerUsername(address account, string memory username, bytes calldata data) external;

    function unregisterUsername(string memory username, bytes calldata data) external;

    function usernameOf(address user) external view returns (string memory);

    function accountOf(string memory name) external view returns (address);

    function getNamespace() external view returns (string memory);

    function getUsernameRules() external view returns (address);
}
