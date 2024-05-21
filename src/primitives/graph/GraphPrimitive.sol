// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

event EdgeAdded();
event EdgeRemoved();

contract GraphPrimitive {

    //------------------------------------------------------------------------------------------------------------------
    // This could be an ACL Primitive.

    modifier writePermissions {
        if (!_hasWritePermissions[msg.sender]) {
            revert();
        }
        _;
    }

    mapping (address => bool) _hasWritePermissions;

    // Functions to grant/revoke write permissions.
    // Functions to add/remove owners that can grant/revoke write permissions.
    //------------------------------------------------------------------------------------------------------------------

    // A `fromNode` and `toNode` naming was avoided as it could be undirected graph.
    // Should directed vs undirected graphs be different primitives? Should multi-edge graphs be a different primitive
    // than single-edge graphs?
    struct Edge {
        bytes node1;
        bytes node2;
        bytes metadata;
    }

    // For example, keccak256("xyz.lens.graph.follow") or keccak256("com.myprivateapp.graph.follow")
    bytes32 _graphNamespaceHash;

    constructor(bytes32 graphNamespaceHash) {
        _graphNamespaceHash = graphNamespaceHash;
    }



    // function addEdge(bytes calldata node1, bytes calldata node2, bytes calldata metadata) external writePermissions {


    //     emit LinkCreated();
       
    // }

}
