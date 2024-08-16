// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IRule} from './IRule.sol';
import {IAccessControl} from 'src/primitives/access-control/IAccessControl.sol';

abstract contract RuleCombinator is IRule {
    // Custom RuleCombinator's operation events
    // TODO: Decide betweet plain initilize event + inner operation events, or single initialize event with params
    event Lens_RuleCombinator_Initialized();
    // event Lens_RuleCombinator_Initialized(CombinationMode combinationMode, address accessControl, bytes addRulesData);
    event Lens_RuleCombinator_CombinationModeChanged(CombinationMode combinationMode);
    event Lens_RuleCombinator_AccessControlChanged(address accessControl);
    event Lens_RuleCombinator_RulesAdded(RuleConfiguration[] addedRules);
    event Lens_RuleCombinator_RulesRemoved(RuleConfiguration[] removedRules);
    event Lens_RuleCombinator_RulesUpdated(RuleConfiguration[] updatedRules);

    IAccessControl internal _accessControl; // TODO: This should be located at some storage place so the inner rules can access it via delegatecall
    address immutable IMPLEMENTATION;

    constructor() {
        IMPLEMENTATION = address(this);
    }

    uint256 constant CHANGE_RULE_ACCESS_CONTROL_RID = uint256(keccak256('CHANGE_RULE_ACCESS_CONTROL'));
    uint256 constant CONFIGURE_RULE_RID = uint256(keccak256('CONFIGURE_RULE'));

    enum CombinationMode {
        AND,
        OR
    }

    // INITIALIZE is just a special operation for (CHANGE_ACCESS_CONTROL + CHANGE_COMBINATION_MODE + ADD)
    enum Operation {
        INITIALIZE, // No Resource ID permission required, the access control is just being provided.
        ADD_RULES, // CONFIGURE_RULE_RID
        REMOVE_RULES, // CONFIGURE_RULE_RID
        UPDATE_RULES, // CONFIGURE_RULE_RID
        CHANGE_COMBINATION_MODE, // CONFIGURE_RULE_RID
        CHANGE_ACCESS_CONTROL // CHANGE_RULE_ACCESS_CONTROL_RID
    }

    struct RuleConfiguration {
        // TODO: We can have Operation here and have one CONFIGURE_RULES operation instead of three ADD/REMOVE/UPDATE
        address contractAddress;
        bytes data;
    }

    address[] internal _rules;
    CombinationMode internal _combinationMode; // Default is AND mode

    function configure(bytes calldata data) external virtual override {
        require(address(this) != IMPLEMENTATION); // Cannot initialize implementation contract
        (Operation operation, bytes memory operationData) = abi.decode(data, (Operation, bytes));
        if (operation == Operation.INITIALIZE) {
            // Initialization: First time being configured. No permissions required in this case.
            _initialize(operationData);
        } else if (operation == Operation.CHANGE_ACCESS_CONTROL) {
            _changeAccessControl(operationData);
        } else {
            require(_canConfigure(msg.sender), 'RuleCombinator: Access denied');
            if (operation == Operation.CHANGE_COMBINATION_MODE) {
                _combinationMode = abi.decode(operationData, (CombinationMode));
            } else {
                RuleConfiguration[] memory rules = abi.decode(operationData, (RuleConfiguration[]));
                if (operation == Operation.ADD_RULES) {
                    _addRules(rules);
                } else if (operation == Operation.REMOVE_RULES) {
                    _removeRules(rules);
                } else if (operation == Operation.UPDATE_RULES) {
                    _updateRules(rules);
                } else {
                    revert('RuleCombinator: Invalid operation');
                }
            }
        }
        emit Lens_RuleConfigured(data);
    }

    function getCombinationMode() external view returns (CombinationMode) {
        return _combinationMode;
    }

    function getRules() external view returns (address[] memory) {
        return _rules;
    }

    function getAccessControl() external view returns (IAccessControl) {
        return _accessControl;
    }

    function _isInitialized() internal view returns (bool) {
        return address(_accessControl) != address(0);
    }

    function _initialize(bytes memory operationData) internal virtual {
        if (_isInitialized()) {
            revert('RuleCombinator: Already initialized');
        }
        (CombinationMode combinationMode, address accessControl, bytes memory addRulesData) = abi.decode(
            operationData,
            (CombinationMode, address, bytes)
        );
        // TODO: We check all with 0, but we could standrize a Resource ID that is used for this address test/check only
        IAccessControl(accessControl).hasAccess(address(0), address(0), 0); // We expect this to not panic.
        _accessControl = IAccessControl(accessControl);
        emit Lens_RuleCombinator_Initialized();
        emit Lens_RuleCombinator_AccessControlChanged(accessControl);
        _combinationMode = combinationMode;
        emit Lens_RuleCombinator_CombinationModeChanged(combinationMode);
        if (addRulesData.length > 0) {
            _addRules(abi.decode(addRulesData, (RuleConfiguration[])));
        }
    }

    function _changeAccessControl(bytes memory operationData) internal virtual {
        require(_canSetAccessControl(msg.sender), 'RuleCombinator: Access denied');
        IAccessControl newAccessControl = IAccessControl(abi.decode(operationData, (address)));
        newAccessControl.hasAccess(address(0), address(0), 0); // We expect this to not panic.
        _accessControl = newAccessControl;
    }

    function _canConfigure(address msgSender) internal virtual returns (bool) {
        return
            _accessControl.hasAccess({
                account: msgSender,
                resourceLocation: address(this),
                resourceId: CONFIGURE_RULE_RID
            });
    }

    function _canSetAccessControl(address msgSender) internal virtual returns (bool) {
        return
            _accessControl.hasAccess({
                account: msgSender,
                resourceLocation: address(this),
                resourceId: CHANGE_RULE_ACCESS_CONTROL_RID
            });
    }

    function _addRules(RuleConfiguration[] memory rules) internal virtual {
        for (uint256 i = 0; i < rules.length; i++) {
            _addRule(rules[i]);
        }
        emit Lens_RuleCombinator_RulesAdded(rules);
    }

    function _addRule(RuleConfiguration memory rule) internal virtual {
        // Check if the rule address already exists in the array
        for (uint256 i = 0; i < _rules.length; i++) {
            if (_rules[i] == rule.contractAddress) {
                revert('RuleCombinator: Rule already exists');
            }
        }
        _rules.push(rule.contractAddress);
        (bool success, ) = rule.contractAddress.delegatecall(abi.encodeCall(IRule.configure, (rule.data)));
        require(success, 'RuleCombinator: Rule configuration failed');
    }

    function _removeRules(RuleConfiguration[] memory rules) internal virtual {
        for (uint256 i = 0; i < rules.length; i++) {
            _removeRule(rules[i]);
        }
        emit Lens_RuleCombinator_RulesRemoved(rules);
    }

    function _removeRule(RuleConfiguration memory rule) internal virtual {
        // Find the rule index and delete it from the _rules array
        // TODO: We can overoptimize this later...
        for (uint256 i = 0; i < _rules.length; i++) {
            if (_rules[i] == rule.contractAddress) {
                delete _rules[i];
                return;
            }
        }
        revert('RuleCombinator: Rule not found');
    }

    function _updateRules(RuleConfiguration[] memory rules) internal virtual {
        for (uint256 i = 0; i < rules.length; i++) {
            _updateRule(rules[i]);
        }
        emit Lens_RuleCombinator_RulesUpdated(rules);
    }

    function _updateRule(RuleConfiguration memory rule) internal virtual {
        // Find the rule index and update it
        // TODO: We can overoptimize this later...
        for (uint256 i = 0; i < _rules.length; i++) {
            if (_rules[i] == rule.contractAddress) {
                (bool success, ) = rule.contractAddress.delegatecall(abi.encodeCall(IRule.configure, (rule.data)));
                require(success, 'RuleCombinator: Rule configuration failed');
                return;
            }
        }
        revert('RuleCombinator: Rule not found');
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
            require(success, 'RuleCombinator: Some rule failed while using AND combination');
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
        revert('RuleCombinator: All rules failed while using OR combination');
    }
}
