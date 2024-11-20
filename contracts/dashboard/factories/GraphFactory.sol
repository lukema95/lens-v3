// SPDX-License-Identifier: UNLICENSED
// Copyright (C) 2024 Lens Labs. All Rights Reserved.
pragma solidity ^0.8.0;

import {IAccessControl} from "./../../core/interfaces/IAccessControl.sol";
import {Graph} from "./../../core/primitives/graph/Graph.sol";
import {RoleBasedAccessControl} from "./../../core/access/RoleBasedAccessControl.sol";
import {RuleChange, DataElement, RuleConfiguration, RuleOperation} from "./../../core/types/Types.sol";
import {IGraphRule} from "./../../core/interfaces/IGraphRule.sol";

contract GraphFactory {
    event Lens_GraphFactory_Deployment(address indexed graph, string metadataURI);

    IAccessControl internal immutable _factoryOwnedAccessControl;
    IGraphRule internal immutable _userBlockingRule;

    constructor(address userBlockingRule) {
        _factoryOwnedAccessControl = new RoleBasedAccessControl({owner: address(this)});
        _userBlockingRule = IGraphRule(userBlockingRule);
    }

    function deployGraph(
        string memory metadataURI,
        IAccessControl accessControl,
        RuleChange[] calldata rules,
        DataElement[] calldata extraData
    ) external returns (address) {
        Graph graph = new Graph(metadataURI, _factoryOwnedAccessControl);
        RuleChange[] memory userBlockingRule = new RuleChange[](1);
        userBlockingRule[0] = RuleChange({
            configuration: RuleConfiguration({ruleAddress: address(_userBlockingRule), configData: "", isRequired: true}),
            operation: RuleOperation.ADD
        });
        graph.changeGraphRules(userBlockingRule);
        graph.changeGraphRules(rules);
        graph.setExtraData(extraData);
        graph.setAccessControl(accessControl);
        emit Lens_GraphFactory_Deployment(address(graph), metadataURI);
        return address(graph);
    }
}
