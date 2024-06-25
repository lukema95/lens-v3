// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IOwnership} from './IOwnership.sol';

contract Ownership is IOwnership {
    event OwnershipTransferInitiated(address indexed currentOwner, address indexed ownerCandidate);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    bool private _transferConfirmedByOwnerCandidate;
    address private _owner;
    address private _ownerCandidate;

    constructor(address owner) {
        _owner = owner;
    }

    function getOwner() external view override returns (address) {
        return _owner;
    }

    /**
     * @dev Enqueues the ownership transfer of the contract to a new account (`newOwnerCandidate`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwnerCandidate) public virtual {
        if (_owner != msg.sender) {
            revert();
        }
        _ownerCandidate = newOwnerCandidate;
        emit OwnershipTransferInitiated(msg.sender, newOwnerCandidate);
    }

    /**
     * @dev Confirms the ownership transfer of the contract to a new account.
     * Must be first called by the owner candidate and then by the current owner.
     * // TODO: Think if maybe this is too much, and just stick to a single confirmation form the candidate.
     */
    function confirmOwnershipTransfer() public virtual {
        if (_transferConfirmedByOwnerCandidate) {
            if (_owner != msg.sender) {
                revert();
            }
            _transferConfirmedByOwnerCandidate = false;
            _confirmOwnershipTransfer(_ownerCandidate);
        } else {
            if (_ownerCandidate != msg.sender) {
                revert();
            }
            _transferConfirmedByOwnerCandidate = true;
        }
    }

    function _confirmOwnershipTransfer(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
