// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

event EdgeAdded();
event EdgeRemoved();

contract AclRepository_Favlour1 {

    mapping (address => bool) _hasWritePermissions;

    function verifyWritePermissions(address requestedAddress) {
        if (!_hasWritePermissions[requestedAddress]) {
            revert();
        }
    }
}

contract AclRepository_Favlour2 {

    address anotherRegistry;

    function checkForWritePermissions(address requestedAddress) {
        if (!anotherRegistry.evalPermission(requestedAddress, WRITE)) {
            revert();
        }
    }
}

interface IAclRepository {

    function hasWritePermissions(address requestedAddress, bytes calldata data) external view returns (bool);
} 

// We kinda need a PROTOCOL for communication between contracts, so we don't need to force interfaces,
// but without interfaces we still have a secure way to communicate between them.

contract GraphPrimitive {

    // ACL stands for Access Control List.
    address aclRepository;

    // We need an IAclRepository interface.

    // modifier writePermissions {
    //     if (!aclRepository.hasWritePermissions(msg.sender)) {
    //         revert();
    //     }
    //     _;
    // }

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



    function addEdge(bytes calldata node1, bytes calldata node2, bytes calldata metadata, bytes calldata aclData) external {
        // ACL Repository has a single restriction which is reverting when needed
        aclRepository.call(abi.encode(aclData, msg.sender));

        // emit LinkCreated();
    }

}

// [Layer1] GraphRestrictions <-- ACL should allow this as writer. This contains the logic to allow certains identities
// to add edges (like you own the identity, you are a delegate, etc), and the logic that restricts the graph properties,
// like single-edged, multi-edged, type of metadata, etc.

// [Layer1] ACL <-- Says who can write to the graph (i.e. add/remove edges) - A more complex and versatile Ownable pattern.

// [Layer0] GraphPrimitive <-- Stores the graph, has a way to add/remove edges from the graph. Adding an edge also adds the nodes in the ends of it.
