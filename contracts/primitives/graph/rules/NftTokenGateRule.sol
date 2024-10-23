// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IGraphRule} from "../IGraphRule.sol";
import {RuleConfiguration} from "../../../types/Types.sol";
import {IERC721} from "../../../../lib/forge-std/src/interfaces/IERC721.sol";
import {IERC1155} from "../../../../lib/forge-std/src/interfaces/IERC1155.sol";

contract NftTokenGateRule is IGraphRule {
    struct RuleStorage {
        TokenStandard tokenStandard;
        address token;
        uint256 amount;
    }

    enum TokenStandard {
        ERC721,
        ERC1155
    }

    RuleStorage internal ruleStorage;

    function configure(bytes calldata data) external override {
        (address token, uint256 amount) = abi.decode(data, (address, uint256));
        _configure(token, amount);
    }

    function processFollow(address followerAccount, address accountToFollow, uint256 followId, bytes calldata data)
        external
        override
    {
        _validateNftTokenOwnership(ruleStorage.token, ruleStorage.amount, followerAccount);
    }

    function processUnfollow(
        address unfollowerAccount,
        address accountToUnfollow,
        uint256 followId,
        bytes calldata data
    ) external override {
        // nothing to do here
    }

    function processFollowRulesChange(address account, RuleConfiguration[] calldata followRules, bytes calldata data)
        external
        override
    {
        // nothing to do here
    }

    function _configure(address token, uint256 amount) internal {
        if (token == address(0)) {
            revert("Errors.invalidTokenAddress()");
        }
        if (amount == 0) {
            revert("Errors.cannotSetZeroAmount()");
        }

        ruleStorage.tokenStandard = _identifyTokenStandard(token);
        ruleStorage.token = token;
        ruleStorage.amount = amount;
    }

    function _validateNftTokenOwnership(address token, uint256 amount, address owner) internal view {
        if (ruleStorage.tokenStandard == TokenStandard.ERC721) {
            _validateErc721TokenOwnership(token, amount, owner);
        } else {
            _validateErc1155TokenOwnership(token, amount, owner);
        }
        uint256 balance = erc20Token.balanceOf(owner);

        if (balance < amount) {
            revert("Errors.notEnoughTokens()");
        }
    }

    function _identifyTokenStandard(address token) internal view returns (NftTokenGateRule.TokenStandard memory) {
        IERC165 tokenContract = IERC165(token);

        if (tokenContract.supportsInterface(0x80ac58cd)) return TokenStandard.ERC721;
        else if (tokenContract.supportsInterface(0xd9b67a26)) return TokenStandard.ERC1155;
        revert("Errors.unsupportedTokenInterface()");
    }

    function _validateErc721TokenOwnership(address token, uint256 amount, address owner) internal view {
        IERC721 erc20Token = IERC721(token);

        uint256 balance = erc20Token.balanceOf(owner);

        if (balance < amount) {
            revert("Errors.notEnoughTokens()");
        }
    }

    function _validateErc1155TokenOwnership(address token, uint256 amount, address owner) internal view {
        IERC1155 erc20Token = IERC1155(token);

        uint256 balance = erc20Token.balanceOf(owner);

        if (balance < amount) {
            revert("Errors.notEnoughTokens()");
        }
    }
}
