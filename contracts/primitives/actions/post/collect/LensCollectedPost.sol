// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LensERC721.sol";
import {IERC7572} from "./IERC7572.sol";
import {LensCollectedPostTokenURIProvider} from "./LensCollectedPostTokenURIProvider.sol";

/**
 * @notice A contract that represents a Lens Collected Post.
 *
 * @dev This contract is used to store the metadata of a Lens Collected Post.
 * It inherits from LensERC721 and implements the IERC7572 interface.
 * The contractURI() function returns the contract-level metadata making it compatible with the EIP-7572 proposed
 * standard and useful for dapps and offchain indexers to show rich information about the post itself.
 */
contract LensCollectedPost is LensERC721, IERC7572 {
    string internal _contractURI;

    constructor(string memory name, string memory symbol, ITokenURIProvider tokenURIProvider)
        LensERC721(name, symbol, tokenURIProvider)
    {
        // TODO: how to handle
        _contractURI = tokenURI(0);
        emit ContractURIUpdated();
    }

    function contractURI() external view returns (string memory) {
        return _contractURI;
    }
}
