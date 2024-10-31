// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {Events} from "./../../types/Events.sol";
import {IAccount, AccountManagerPermissions} from "./IAccount.sol";

contract Account is IAccount, Ownable {
    string internal _metadataURI; // TODO: Add getter/setter/internal etc
    mapping(address => AccountManagerPermissions) internal _accountManagerPermissions; // TODO: Add getter/setter/internal etc

    constructor(
        address owner,
        string memory metadataURI,
        address[] memory accountManagers,
        AccountManagerPermissions[] memory accountManagerPermissions
    ) Ownable() {
        _metadataURI = metadataURI;
        for (uint256 i = 0; i < accountManagers.length; i++) {
            _accountManagerPermissions[accountManagers[i]] = accountManagerPermissions[i];
            emit Lens_Account_AccountManagerAdded(accountManagers[i], accountManagerPermissions[i]);
        }
        _transferOwnership(owner);
        emit Lens_Account_MetadataURISet(metadataURI);
        emit Events.Lens_Contract_Deployed("account", "lens.account", "account", "lens.account");
    }

    // Owner Only functions

    function addAccountManager(address accountManager, AccountManagerPermissions calldata accountManagerPermissions)
        external
        override
        onlyOwner
    {
        require(!_accountManagerPermissions[accountManager].canExecuteTransactions, "Account manager already exists");
        _accountManagerPermissions[accountManager] = accountManagerPermissions;
        emit Lens_Account_AccountManagerAdded(accountManager, accountManagerPermissions);
    }

    function removeAccountManager(address accountManager) external override onlyOwner {
        require(_accountManagerPermissions[accountManager].canExecuteTransactions, "Account manager already exists");
        delete _accountManagerPermissions[accountManager];
        emit Lens_Account_AccountManagerRemoved(accountManager);
    }

    function updateAccountManagerPermissions(
        address accountManager,
        AccountManagerPermissions calldata accountManagerPermissions
    ) external override onlyOwner {
        require(_accountManagerPermissions[accountManager].canExecuteTransactions, "Account manager does not exist");
        require(accountManagerPermissions.canExecuteTransactions, "Cannot remove execution permissions");
        _accountManagerPermissions[accountManager] = accountManagerPermissions;
        emit Lens_Account_AccountManagerUpdated(accountManager, accountManagerPermissions);
    }

    function setMetadataURI(string calldata metadataURI) external override {
        if (msg.sender != owner()) {
            require(_accountManagerPermissions[msg.sender].canSetMetadataURI, "No permissions to set metadata URI");
        }
        _metadataURI = metadataURI;
        emit Lens_Account_MetadataURISet(metadataURI);
    }

    function executeTransaction(address to, uint256 value, bytes calldata data) external payable override {
        if (msg.sender != owner()) {
            require(
                _accountManagerPermissions[msg.sender].canExecuteTransactions, "No permissions to execute transactions"
            );
            if (value > 0) {
                require(
                    _accountManagerPermissions[msg.sender].canTransferNative, "No permissions to transfer native tokens"
                );
            }
            if (_isTransferRelatedSelector(bytes4(data[:4]))) {
                require(_accountManagerPermissions[msg.sender].canTransferTokens, "No permissions to transfer tokens");
            }
        }
        (bool success,) = to.call{value: value}(data);
        require(success, "Transaction execution failed");
        emit Lens_Account_TransactionExecuted(to, value, data, msg.sender);
    }

    receive() external payable override {}

    function _isTransferRelatedSelector(bytes4 selector) internal pure returns (bool) {
        // Checking only for ERC20, ERC721, ERC1155 selectors for now
        return selector == bytes4(keccak256("transfer(address,uint256)"))
            || selector == bytes4(keccak256("transferFrom(address,address,uint256)"))
            || selector == bytes4(keccak256("safeTransferFrom(address,address,uint256)"))
            || selector == bytes4(keccak256("safeTransferFrom(address,address,uint256,bytes)"))
            || selector == bytes4(keccak256("safeTransferFrom(address,address,uint256,uint256,bytes)"))
            || selector == bytes4(keccak256("safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)"))
            || selector == bytes4(keccak256("approve(address,uint256)"))
            || selector == bytes4(keccak256("setApprovalForAll(address,bool)"));
    }

    function _transferOwnership(address newOwner) internal override {
        super._transferOwnership(newOwner);
        emit Lens_Account_OwnerTransferred(newOwner);
    }
}
