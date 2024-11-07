// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IFeed} from "../feed/IFeed.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import {ITokenURIProvider} from "../base/ITokenURIProvider.sol";

contract LensCollectedPostTokenURIProvider is ITokenURIProvider {
    using StringsUpgradeable for uint256;

    address private immutable _feed;
    uint256 private immutable _postId;

    constructor(address feed, uint256 postId) {
        _feed = feed;
        _postId = postId;
    }

    function tokenURI(uint256 tokenId) external view override returns (string memory) {
        return IFeed(_feed).getPost(_postId).contentURI;
    }
}
