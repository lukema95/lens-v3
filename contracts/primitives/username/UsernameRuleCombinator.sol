// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {RuleCombinator} from "./../rules/RuleCombinator.sol";
import {IUsernameRule} from "./IUsernameRule.sol";

contract UsernameRuleCombinator is RuleCombinator, IUsernameRule {
    function processRegistering(address originalMsgSender, address account, string memory username, bytes memory data)
        external
        override
    {
        bytes[] memory ruleSpecificDatas = abi.decode(data, (bytes[]));
        bytes[] memory datas = new bytes[](_rules.length);
        for (uint256 i = 0; i < _rules.length; i++) {
            datas[i] = abi.encodeWithSelector(
                IUsernameRule.processRegistering.selector, originalMsgSender, account, username, ruleSpecificDatas[i]
            );
        }
        _processRules(datas);
    }

    function processUnregistering(address originalMsgSender, address account, string memory username, bytes memory data)
        external
        override
    {
        bytes[] memory ruleSpecificDatas = abi.decode(data, (bytes[]));
        bytes[] memory datas = new bytes[](_rules.length);
        for (uint256 i = 0; i < _rules.length; i++) {
            datas[i] = abi.encodeWithSelector(
                IUsernameRule.processUnregistering.selector, originalMsgSender, account, username, ruleSpecificDatas[i]
            );
        }
        _processRules(datas);
    }
}
