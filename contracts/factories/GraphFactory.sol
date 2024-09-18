// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccessControl} from "./../primitives/access-control/IAccessControl.sol";
import {Graph} from "./../primitives/graph/Graph.sol";
import {OwnerOnlyAccessControl} from "./../primitives/access-control/OwnerOnlyAccessControl.sol";
import {IGraphRule} from "./../primitives/graph/IGraphRule.sol";

contract GraphFactory {
    event Lens_GraphFactory_NewGraphInstance(
        address indexed graphInstance,
        string metadataURI,
        IAccessControl accessControl,
        IGraphRule rules,
        bytes rulesInitializationData
    );

    IAccessControl internal _accessControl;
    IAccessControl internal immutable _factoryOwnedAccessControl;

    uint256 constant CHANGE_ACCESS_CONTROL_RID = uint256(keccak256("CHANGE_ACCESS_CONTROL"));
    uint256 constant DEPLOY_GRAPH_RID = uint256(keccak256("DEPLOY_GRAPH"));

    function setAccessControl(IAccessControl accessControl) external {
        require(
            IAccessControl(_accessControl).hasAccess({
                account: msg.sender,
                resourceLocation: address(this),
                resourceId: CHANGE_ACCESS_CONTROL_RID
            })
        ); // msg.sender must have permissions to change access control
        accessControl.hasAccess(address(0), address(0), 0); // We expect this to not panic.
        _accessControl = accessControl;
    }

    constructor(IAccessControl accessControl) {
        _accessControl = accessControl;
        _factoryOwnedAccessControl = new OwnerOnlyAccessControl({owner: address(this)});
    }

    function deploy__Immutable_NoRules(string memory metadataURI, IAccessControl accessControl)
        external
        returns (address)
    {
        require(
            IAccessControl(_accessControl).hasAccess({
                account: msg.sender,
                resourceLocation: address(this),
                resourceId: DEPLOY_GRAPH_RID
            })
        ); // msg.sender must have permissions to deploy GraphPrimitive
        address graphInstance = address(new Graph(metadataURI, accessControl));
        emit Lens_GraphFactory_NewGraphInstance({
            graphInstance: graphInstance,
            metadataURI: metadataURI,
            accessControl: accessControl,
            rules: IGraphRule(address(0)),
            rulesInitializationData: ""
        });
        return graphInstance;
    }

    // function deploy__Immutable_WithRules(
    //     string memory metadataURI,
    //     IAccessControl accessControl,
    //     bytes calldata rulesInitializationData
    // ) external returns (address) {
    //     require(
    //         IAccessControl(_accessControl).hasAccess({
    //             account: msg.sender,
    //             resourceLocation: address(this),
    //             resourceId: DEPLOY_GRAPH_RID
    //         })
    //     ); // msg.sender must have permissions to deploy
    //     Graph graphInstance = new Graph(metadataURI, _factoryOwnedAccessControl);
    //     IGraphRule rulesInstance = new GraphRuleCombinator();
    //     rulesInstance.configure(rulesInitializationData);
    //     graphInstance.setGraphRules(rulesInstance);
    //     graphInstance.setAccessControl(accessControl);
    //     emit Lens_GraphFactory_NewGraphInstance({
    //         graphInstance: address(graphInstance),
    //         metadataURI: metadataURI,
    //         accessControl: accessControl,
    //         rules: rulesInstance,
    //         rulesInitializationData: rulesInitializationData
    //     });
    //     return address(graphInstance);
    // }
}
