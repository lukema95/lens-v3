// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IRules} from './IRules.sol';
import {IAccessControl} from 'src/primitives/access-control/IAccessControl.sol';

abstract contract RulesCombinator is IRules {
    IAccessControl internal _accessControl; // TODO: This should be located at some storage place so the inner rules can access it via delegatecall
    address immutable IMPLEMENTATION;

    constructor() {
        IMPLEMENTATION = address(this);
    }

    struct Permissions {
        bool canSetAccessControl;
        bool canSetRolePermissions;
        bool canConfigure;
    }

    mapping(uint256 => Permissions) _rolePermissions; // TODO: Think on the naming: "lens.RulesCombinator.UsernameRulesCombinator.rolePermissions"

    enum CombinationMode {
        AND,
        OR
    }

    enum Operation {
        INITIALIZE, // Can be called by anyone if not initialized
        ADD, // _canConfigure()
        REMOVE, // _canConfigure()
        UPDATE, // _canConfigure()
        SET_COMBINATION_MODE, // _canConfigure()
        SET_ACCESS_CONTROL, // _canSetAccessControl()
        SET_ROLES_PERMISSIONS // _canSetRolePermissions()
    }

    struct RuleConfiguration {
        address contractAddress;
        bytes data;
        // TODO: We can have Operation here and have one CONFIGURE_RULES operation instead of three ADD/REMOVE/UPDATE
    }

    address[] internal _rules;
    CombinationMode internal _combinationMode; // Default is AND mode
    bool internal _initialized;

    // configure() function of the RuleCombinator has two different usages:
    // 1st time use (ala initialization)
    // non-1st time use (configuration updates - add rules, remove rules, etc)
    //
    // Configuration can do magic:
    // - You pass an operation: Add, Remove, Update
    // - You pass a list of rules to remove, or to update or to add
    function configure(bytes calldata data) external virtual {
        require(address(this) != IMPLEMENTATION); // Cannot initialize implementation contract

        (Operation operation, bytes memory operationData) = abi.decode(data, (Operation, bytes));

        if (operation == Operation.INITIALIZE) {
            // Initialization: First time being configured.
            if (_initialized) {
                revert('RulesCombinator: Already initialized');
            }
            _initialize(operationData);
            _initialized = true;
        } else if (operation == Operation.SET_ACCESS_CONTROL) {
            require(_canSetAccessControl(msg.sender), 'RulesCombinator: Access denied');
            _accessControl = IAccessControl(abi.decode(operationData, (address)));
        } else if (operation == Operation.SET_ROLES_PERMISSIONS) {
            require(_canSetRolePermissions(msg.sender), 'RulesCombinator: Access denied');
            _setRolesPermissions(operationData);
        } else {
            require(_initialized, 'RulesCombinator: Not initialized');
            require(_canConfigure(msg.sender), 'RulesCombinator: Access denied');

            if (operation == Operation.SET_COMBINATION_MODE) {
                _combinationMode = abi.decode(operationData, (CombinationMode));
            } else {
                RuleConfiguration[] memory rules = abi.decode(operationData, (RuleConfiguration[]));

                if (operation == Operation.ADD) {
                    _addRules(rules);
                } else if (operation == Operation.REMOVE) {
                    _removeRules(rules);
                } else if (operation == Operation.UPDATE) {
                    _updateRules(rules);
                } else {
                    revert('RulesCombinator: Invalid operation');
                }
            }
        }
    }

    function _initialize(bytes memory operationData) internal virtual {
        (
            CombinationMode combinationMode,
            address accessControl,
            uint256 ownerRoleId,
            bool canSetAccessControl,
            bool canSetRolePermissions,
            bool canConfigure,
            bytes memory addRulesData
        ) = abi.decode(operationData, (CombinationMode, address, uint256, bool, bool, bool, bytes));
        _combinationMode = combinationMode;
        _accessControl = IAccessControl(accessControl);
        _rolePermissions[ownerRoleId] = Permissions(canSetAccessControl, canSetRolePermissions, canConfigure);
        if (addRulesData.length > 0) {
            _addRules(abi.decode(addRulesData, (RuleConfiguration[])));
        }
    }

    function _canConfigure(address msgSender) internal virtual returns (bool) {
        return _rolePermissions[_accessControl.getRole(msgSender)].canConfigure;
    }

    function _canSetAccessControl(address msgSender) internal virtual returns (bool) {
        return _rolePermissions[_accessControl.getRole(msgSender)].canSetAccessControl;
    }

    function _canSetRolePermissions(address msgSender) internal virtual returns (bool) {
        return _rolePermissions[_accessControl.getRole(msgSender)].canSetRolePermissions;
    }

    function _setRolesPermissions(bytes memory data) internal virtual {
        (uint256[] memory roleIds, Permissions[] memory permissions) = abi.decode(data, (uint256[], Permissions[]));
        require(roleIds.length == permissions.length, 'RulesCombinator: Invalid data');
        for (uint256 i = 0; i < roleIds.length; i++) {
            _rolePermissions[roleIds[i]] = permissions[i];
        }
    }

    function getCombinationMode() external view returns (CombinationMode) {
        return _combinationMode;
    }

    function _addRules(RuleConfiguration[] memory rules) internal virtual {
        for (uint256 i = 0; i < rules.length; i++) {
            _addRule(rules[i]);
        }
    }

    function _addRule(RuleConfiguration memory rule) internal virtual {
        // Check if the rule address already exists in the array
        for (uint256 i = 0; i < _rules.length; i++) {
            if (_rules[i] == rule.contractAddress) {
                revert('RulesCombinator: Rule already exists');
            }
        }
        _rules.push(rule.contractAddress);
        IRules(rule.contractAddress).configure(rule.data);
    }

    function _removeRules(RuleConfiguration[] memory rules) internal virtual {
        for (uint256 i = 0; i < rules.length; i++) {
            _removeRule(rules[i]);
        }
    }

    function _removeRule(RuleConfiguration memory rule) internal virtual {
        // Find the rule index and delete it from the _rules array
        for (uint256 i = 0; i < _rules.length; i++) {
            if (_rules[i] == rule.contractAddress) {
                delete _rules[i];
                return;
            }
        }
        revert('RulesCombinator: Rule not found');
    }

    function _updateRules(RuleConfiguration[] memory rules) internal virtual {
        for (uint256 i = 0; i < rules.length; i++) {
            _updateRule(rules[i]);
        }
    }

    function _updateRule(RuleConfiguration memory rule) internal virtual {
        // Find the rule index and update it
        for (uint256 i = 0; i < _rules.length; i++) {
            if (_rules[i] == rule.contractAddress) {
                IRules(rule.contractAddress).configure(rule.data);
                return;
            }
        }
        revert('RulesCombinator: Rule not found');
    }

    function _setRules(address[] memory rules, CombinationMode combinationMode) internal virtual {
        rules = rules;
        _combinationMode = combinationMode;
    }

    function getRules() external view returns (address[] memory, CombinationMode) {
        return (_rules, _combinationMode);
    }

    function _processRules(bytes[] memory datas) internal virtual {
        if (_combinationMode == CombinationMode.AND) {
            _processRules_AND(datas);
        } else {
            _processRules_OR(datas);
        }
    }

    function _processRules_AND(bytes[] memory datas) internal virtual {
        for (uint256 i = 0; i < _rules.length; i++) {
            (bool success, ) = _rules[i].delegatecall(datas[i]);
            if (!success) {
                revert('RulesCombinator: Some rule failed while using AND combination');
            }
        }
        return; // If it didn't revert above - all passed
    }

    function _processRules_OR(bytes[] memory datas) internal virtual {
        for (uint256 i = 0; i < _rules.length; i++) {
            (bool success, ) = _rules[i].delegatecall(datas[i]);
            if (success) {
                return; // If any of the rules passed, we can return
            }
        }
        revert('RulesCombinator: All rules failed while using OR combination');
    }
}
