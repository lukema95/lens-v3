// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {Events} from "./../../types/Events.sol";
import {IAccount} from "./IAccount.sol";

import {RoleBasedAccessControl} from "./../access-control/RoleBasedAccessControl.sol";
import {IRoleBasedAccessControl, Access} from "./../access-control/IRoleBasedAccessControl.sol";

contract Account is IAccount, Ownable {
    event Lens_Account_AccountManagerAdded(
        address indexed accountManager, uint256[] executionRoles, uint256[] primitiveRoles
    );
    event Lens_Account_AccountManagerExecutionRoleAdded(address indexed accountManager, uint256 executionRole);
    event Lens_Account_AccountManagerPrimitiveRoleAdded(address indexed accountManager, uint256 primitiveRole);
    event Lens_Account_AccountManagerExecutionRoleRemoved(address indexed accountManager, uint256 executionRole);
    event Lens_Account_AccountManagerPrimitiveRoleRemoved(address indexed accountManager, uint256 primitiveRole);

    event Lens_Account_ExecutionRolePermissionDefined(
        uint256 indexed roleId, address indexed contractAddress, uint256 indexed permissionId, Access access
    );
    event Lens_Account_PrimitiveRolePermissionDefined(
        uint256 indexed roleId, uint256 indexed permissionId, Access access
    );

    mapping(address => uint256[]) public _executionRoles;
    mapping(address => uint256[]) public _primitiveRoles;
    string public metadataURI; // TODO: Add getter/setter/internal etc
    IRoleBasedAccessControl public executionAccessControl;
    IRoleBasedAccessControl public primitiveAccessControl;

    constructor(
        address _owner,
        string memory _metadataURI,
        address[] memory _accountManagers,
        uint256[][] memory executionRoles,
        uint256[][] memory primitiveRoles
    ) Ownable() {
        metadataURI = _metadataURI;
        executionAccessControl = new RoleBasedAccessControl(address(this));
        primitiveAccessControl = new RoleBasedAccessControl(address(this));
        for (uint256 i = 0; i < _accountManagers.length; i++) {
            for (uint256 j = 0; j < executionRoles[i].length; j++) {
                executionAccessControl.grantRole(_accountManagers[i], executionRoles[i][j]);
                _executionRoles[_accountManagers[i]].push(executionRoles[i][j]);
            }
            for (uint256 j = 0; j < primitiveRoles[i].length; j++) {
                primitiveAccessControl.grantRole(_accountManagers[i], primitiveRoles[i][j]);
                _primitiveRoles[_accountManagers[i]].push(primitiveRoles[i][j]);
            }
            emit Lens_Account_AccountManagerAdded(_accountManagers[i], executionRoles[i], primitiveRoles[i]);
        }
        _transferOwnership(_owner);
        emit Lens_Account_MetadataURISet(_metadataURI);
        emit Events.Lens_Contract_Deployed("account", "lens.account", "account", "lens.account");
    }

    // Owner Only functions

    function addAccountManager(
        address _accountManager,
        uint256[] calldata executionRoles,
        uint256[] calldata primitiveRoles
    ) external override onlyOwner {
        for (uint256 i = 0; i < executionRoles.length; i++) {
            executionAccessControl.grantRole(_accountManager, executionRoles[i]);
            _executionRoles[_accountManager].push(executionRoles[i]);
        }
        for (uint256 i = 0; i < primitiveRoles.length; i++) {
            primitiveAccessControl.grantRole(_accountManager, primitiveRoles[i]);
            _primitiveRoles[_accountManager].push(primitiveRoles[i]);
        }
        emit Lens_Account_AccountManagerAdded(_accountManager, executionRoles, primitiveRoles);
    }

    function removeAccountManager(address _accountManager) external override onlyOwner {
        for (uint256 i = _executionRoles[_accountManager].length - 1; i >= 0; i--) {
            executionAccessControl.revokeRole(_accountManager, _executionRoles[_accountManager][i]);
            _executionRoles[_accountManager].pop();
        }
        for (uint256 i = _primitiveRoles[_accountManager].length - 1; i >= 0; i--) {
            primitiveAccessControl.revokeRole(_accountManager, _primitiveRoles[_accountManager][i]);
            _primitiveRoles[_accountManager].pop();
        }
        emit Lens_Account_AccountManagerRemoved(_accountManager);
    }

    function addAccountManagerRoles(
        address _accountManager,
        uint256[] calldata executionRoles,
        uint256[] calldata primitiveRoles
    ) external override onlyOwner {
        for (uint256 i = 0; i < executionRoles.length; i++) {
            executionAccessControl.grantRole(_accountManager, executionRoles[i]);
            _executionRoles[_accountManager].push(executionRoles[i]);
            emit Lens_Account_AccountManagerExecutionRoleAdded(_accountManager, executionRoles[i]);
        }
        for (uint256 i = 0; i < primitiveRoles.length; i++) {
            primitiveAccessControl.grantRole(_accountManager, primitiveRoles[i]);
            _primitiveRoles[_accountManager].push(primitiveRoles[i]);
            emit Lens_Account_AccountManagerPrimitiveRoleAdded(_accountManager, primitiveRoles[i]);
        }
    }

    function removeAccountManagerRoles(
        address _accountManager,
        uint256[] calldata executionRoles,
        uint256[] calldata primitiveRoles
    ) external override onlyOwner {
        for (uint256 i = 0; i < executionRoles.length; i++) {
            executionAccessControl.revokeRole(_accountManager, executionRoles[i]);
            // TODO: Code deletion of the role from _executionRoles[_accountManager] array
            // _executionRoles[_accountManager].pop();
            emit Lens_Account_AccountManagerExecutionRoleRemoved(_accountManager, executionRoles[i]);
        }
        for (uint256 i = 0; i < primitiveRoles.length; i++) {
            primitiveAccessControl.revokeRole(_accountManager, primitiveRoles[i]);
            // TODO: Code deletion of the role from _primitiveRoles[_accountManager] array
            // _primitiveRoles[_accountManager].pop();
            emit Lens_Account_AccountManagerPrimitiveRoleRemoved(_accountManager, primitiveRoles[i]);
        }
        if (_executionRoles[_accountManager].length == 0 && _primitiveRoles[_accountManager].length == 0) {
            emit Lens_Account_AccountManagerRemoved(_accountManager);
        }
    }

    function defineExecutionRolePermissions(
        uint256 roleId,
        address[] calldata contractAddresses,
        uint256[] calldata permissionIds,
        Access[] calldata accesses
    ) external override onlyOwner {
        require(
            contractAddresses.length == permissionIds.length && contractAddresses.length == accesses.length,
            "Invalid input lengths"
        );
        for (uint256 i = 0; i < contractAddresses.length; i++) {
            executionAccessControl.setAccess(roleId, contractAddresses[i], permissionIds[i], accesses[i]);
            // TODO: I guess we will be asked to replace this with a usual ADDED/UPDATED/REMOVED events
            emit Lens_Account_ExecutionRolePermissionDefined(
                roleId, contractAddresses[i], permissionIds[i], accesses[i]
            );
        }
    }

    function definePrimitiveRolePermissions(
        uint256 roleId,
        uint256[] calldata permissionIds,
        Access[] calldata accesses
    ) external override onlyOwner {
        require(permissionIds.length == accesses.length, "Invalid input lengths");
        for (uint256 i = 0; i < permissionIds.length; i++) {
            primitiveAccessControl.setAccess(roleId, address(this), permissionIds[i], accesses[i]);
            // TODO: I guess we will be asked to replace this with a usual ADDED/UPDATED/REMOVED events
            emit Lens_Account_PrimitiveRolePermissionDefined(roleId, permissionIds[i], accesses[i]);
        }
    }

    function setMetadataURI(string calldata _metadataURI) external override {
        require(
            primitiveAccessControl.hasAccess(msg.sender, address(this), uint256(keccak256("SET_METADATA_URI"))),
            "No permissions to setMetadataURI"
        ); // TODO: Add a constant for PID
        metadataURI = _metadataURI;
        emit Lens_Account_MetadataURISet(_metadataURI);
    }

    function executeTransaction(address to, uint256 value, bytes calldata data) external payable override {
        require(
            to != address(executionAccessControl),
            "Cannot execute transactions on the execution access control contract"
        );
        require(
            to != address(primitiveAccessControl),
            "Cannot execute transactions on the primitive access control contract"
        );
        // Copy first 4 bytes of calldata into function selector
        bytes4 functionSelector = bytes4(data[:4]);
        require(
            executionAccessControl.hasAccess(msg.sender, to, uint256(uint32(functionSelector))),
            "Sender does not have access to this function"
        );
        // TODO: We need to add a permission to send value to the AccessControl (but we can't, cause it's not changable)
        (bool success,) = to.call{value: value}(data);
        require(success, "Transaction execution failed");
        emit TransactionExecuted(to, value, data, msg.sender);
    }

    receive() external payable override {}

    function _transferOwnership(address newOwner) internal override {
        super._transferOwnership(newOwner);
        emit Lens_Account_OwnerTransferred(newOwner);
    }
}
