// SPDX-License-Identifier: UNLICENSED
// Copyright (C) 2024 Lens Labs. All Rights Reserved.
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import {IAccessControl} from "../../contracts/core/interfaces/IAccessControl.sol";
import {OwnerAdminOnlyAccessControl} from "../../contracts/dashboard/access/OwnerAdminOnlyAccessControl.sol";
import {IGraph} from "../../contracts/core/interfaces/IGraph.sol";
import {Graph} from "../../contracts/core/primitives/graph/Graph.sol";
import {RuleExecutionData, SourceStamp} from "../../contracts/core/types/Types.sol";

contract GraphTest is Test {
    IAccessControl accessControl;
    IGraph graph;

    address source = makeAddr("SOURCE");
    address target = makeAddr("TARGET");

    function _emptyExecutionData() internal pure returns (RuleExecutionData memory) {
        return RuleExecutionData(new bytes[](0), new bytes[](0));
    }

    function _emptySourceStamp() internal pure returns (SourceStamp memory) {
        return SourceStamp(address(0), 0, 0, new bytes(0));
    }

    function setUp() public {
        accessControl = new OwnerAdminOnlyAccessControl(address(this));
        graph = new Graph({metadataURI: "uri://graph-metadata", accessControl: IAccessControl(accessControl)});
    }

    function testFollowAndUnfollow() public {
        vm.prank(source);
        graph.follow(source, target, 0, _emptyExecutionData(), _emptyExecutionData(), _emptySourceStamp());

        vm.prank(source);
        graph.unfollow(source, target, _emptyExecutionData(), _emptySourceStamp());
    }
}
