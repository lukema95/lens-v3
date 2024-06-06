// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
    Let every primitive be kinda "smart wallet", meaning - admin(s) can call stuff form the primitive as a msg.sender.
    This will allow seamless linking of any primitives together without a single standard interface.
*/

// Then we can have a function like this in every primitive:

contract Primitive {
    address internal _admin;

    // Caution: this might be very dangerous, but it's admin only.
    function callTo(address to, bytes calldata data) external payable {
        require(msg.sender == _admin);
        require(to != address(this));
        (bool success, ) = (to.call{value: msg.value}(data));
        require(success);
    }
}

// And can have registries like these:

contract CommunityPublicationSystemsRegistry {
    mapping(address community => address publicationSystem) internal _communityPublicationSystems;

    function registerPublicationSystem(address publicationSystem) external {
        require(_communityPublicationSystems[msg.sender] == address(0));
        _communityPublicationSystems[msg.sender] = publicationSystem;
    }
}

contract Registry {
    function register(address primitive, bytes calldata primitiveType) external {
        // msg.sender registers primitive as type
    }
}
