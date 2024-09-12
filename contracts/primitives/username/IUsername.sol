// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IUsernameRule} from "./IUsernameRule.sol";
import {DataElement} from "../../types/Types.sol";

interface IUsername {
    event Lens_Username_RulesSet(address indexed usernameRules);

    event Lens_Username_Registered(string username, address indexed account, bytes data);

    event Lens_Username_Unregistered(string username, address indexed previousAccount, bytes data);

    event Lens_Username_ExtraDataSet(bytes32 indexed key, bytes value, bytes indexed valueIndexed);

    function setExtraData(DataElement[] calldata extraDataToSet) external;

    function setUsernameRules(IUsernameRule usernameRules) external;

    function registerUsername(address account, string memory username, bytes calldata data) external;

    function unregisterUsername(string memory username, bytes calldata data) external;

    function usernameOf(address user) external view returns (string memory);

    function accountOf(string memory name) external view returns (address);

    function getNamespace() external view returns (string memory);

    function getUsernameRules() external view returns (address);

    function getExtraData(bytes32 key) external view returns (bytes memory);
}
