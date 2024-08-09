// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IOwnership} from './Ownership.sol';

contract LensDiamond {
    IOwnership immutable _ownership; // TODO: Can this be considered 100% safe? Or can somehow immutable constant be manipulated with some malicious facet? I guess it is 100% safe...

    constructor(address ownership) {
        _ownership = IOwnership(ownership);
    }

    // This is just a draft, but the idea is that if the immutable constant `_ownership` is safe (i.e. no facet can touch it),
    // then it means the owner cannot be modified by a malicious facet, and even when malicious facets could do a lot of harm,
    // they will never be able to make the diamond to lose its owner.
    // As a consequence of this, having a facet add/remove hardcoded function that is only available for the owner,
    // allows to recover any facet state at any time.
    // function editFacets(address facet, bytes4[] calldata functionSelectors, bool[] calldata isAdding) external {
    //     if (_ownership.getOwner() != msg.sender) {
    //         revert();
    //     }
    //     // TODO: add/remove facets
    // }

    fallback() external payable {
        // TODO: Code to find facet and delegate call
    }

    receive() external payable {
        // This function was added just to avoid compiler warnings.
        revert();
    }
}
