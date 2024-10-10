// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

import {Events} from "./../../types/Events.sol";
import {IAccount} from "./IAccount.sol";

contract Account is IAccount, Initializable, UUPSUpgradeable {
    address public owner;
    mapping(address => bool) public accountManagers;
    string public metadataURI; // TODO: Add getter/setter/internal etc

    constructor(address _owner, string memory _metadataURI, address[] memory _accountManagers) {
        initialize(_owner, _metadataURI, _accountManagers);
    }

    function initialize(address _owner, string memory _metadataURI, address[] memory _accountManagers)
        public
        initializer
    {
        owner = _owner;
        metadataURI = _metadataURI;
        for (uint256 i = 0; i < _accountManagers.length; i++) {
            accountManagers[_accountManagers[i]] = true;
            emit Lens_Account_AccountManagerAdded(_accountManagers[i]);
        }
        emit Lens_Account_MetadataURISet(_metadataURI);
        emit Lens_Account_OwnerSet(_owner);
        emit Events.Lens_Contract_Deployed("account", "lens.account", "account", "lens.account");
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyOwnerOrManager() {
        require(msg.sender == owner || accountManagers[msg.sender], "Not authorized");
        _;
    }

    // Owner Only functions

    function addAccountManager(address _accountManager) external override onlyOwner {
        accountManagers[_accountManager] = true;
        emit Lens_Account_AccountManagerAdded(_accountManager);
    }

    function removeAccountManager(address _accountManager) external override onlyOwner {
        delete accountManagers[_accountManager];
        emit Lens_Account_AccountManagerRemoved(_accountManager);
    }

    function setMetadataURI(string calldata _metadataURI) external override onlyOwner {
        metadataURI = _metadataURI;
        emit Lens_Account_MetadataURISet(_metadataURI);
    }

    function executeTransaction(address to, uint256 value, bytes calldata data)
        external
        payable
        override
        onlyOwnerOrManager
    {
        // TODO: Can add here a distinction for AccountManagers and which function selectors they can call
        (bool success,) = to.call{value: value}(data);
        require(success, "Transaction execution failed");
        emit TransactionExecuted(to, value, data, msg.sender);
    }

    receive() external payable override {}

    function _authorizeUpgrade(address) internal override onlyOwner {}
}
