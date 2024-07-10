// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RuleCombinator {
    enum CombinationMode {
        AND_OR,
        OR_AND
    }

    address[][] internal _rules;
    CombinationMode internal _combinationMode;

    function setRules(address[][] memory rules, CombinationMode combinationMode) external {
        rules = rules;
        _combinationMode = combinationMode;
    }

    function getRules() external view returns (address[][] memory, CombinationMode) {
        return (_rules, _combinationMode);
    }

    function processRules(bytes4 ruleFunctionSignature, bytes[][] memory data) external {
        if (_combinationMode == CombinationMode.AND_OR) {
            _processRules_AND_OR(ruleFunctionSignature, data);
        } else {
            _processRules_OR_AND(ruleFunctionSignature, data);
        }
    }

    function _processRules_AND_OR(bytes4 ruleFunctionSignature, bytes[][] memory data) internal {
        for (uint256 i = 0; i < _rules.length; i++) {
            address[] memory innerRuleSet = _rules[i];
            bool innerTruth = false;
            for (uint256 j = 0; j < innerRuleSet.length; j++) {
                (bool success, ) = innerRuleSet[j].delegatecall(
                    abi.encodeWithSelector(ruleFunctionSignature, data[i][j])
                );
                if (success) {
                    innerTruth = true;
                    break;
                }
            }
            if (!innerTruth) {
                revert('RuleCombinator: Innter OR Rule failed, so outer AND Rule will fail now');
            }
        }
        // If it didn't revert above - all passed
    }

    function _processRules_OR_AND(bytes4 ruleFunctionSignature, bytes[][] memory data) internal {
        for (uint256 i = 0; i < _rules.length; i++) {
            address[] memory innerRuleSet = _rules[i];
            bool innerTruth = true;
            for (uint256 j = 0; j < innerRuleSet.length; j++) {
                (bool success, ) = innerRuleSet[j].delegatecall(
                    abi.encodeWithSelector(ruleFunctionSignature, data[i][j])
                );
                if (!success) {
                    innerTruth = false;
                    break;
                }
            }
            if (innerTruth) {
                return; // One of the inner AND rules passed, so the outer OR rule passes now
            }
        }
        revert('RuleCombinator: All inner AND Rules failed, so outer OR Rule did not pass either');
    }
}
