// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {
    IBaseCollectAction,
    BaseCollectActionConfigureData,
    BaseCollectActionExecuteData,
    CollectFee
} from "./IBaseCollectAction.sol";
import {IFeed} from "../feed/IFeed.sol";
import {IGraph} from "../graph/IGraph.sol";

abstract contract BaseCollectAction is IBaseCollectAction {
    using SafeERC20 for IERC20;

    uint16 internal constant BPS_MAX = 10000;

    struct BaseCollectActionStorage {
        mapping(address => mapping(uint256 => BaseCollectActionExecuteData)) collectData;
    }

    // keccak256('lens.collect.action.storage')
    bytes32 constant COLLECT_ACTION_STORAGE_SLOT = 0xe1f8cf4605de41364c4d03a174be3c746589cc2d9f5771f05a87d2038718aa33;

    function $collectDataStorage() private pure returns (BaseCollectActionStorage storage _storage) {
        assembly {
            _storage.slot := COLLECT_ACTION_STORAGE_SLOT
        }
    }

    function configure(address feed, uint256 postId, bytes calldata data) external override returns (bytes memory) {
        _validateSender(msg.sender, feed, postId);

        BaseCollectActionConfigureData memory baseConfigData = abi.decode(data, (BaseCollectActionConfigureData));
        _validateBaseConfigureData(baseConfigData);

        _storeBaseConfigureData(feed, postId, baseConfigData);

        emit Lens_PostAction_Configured(feed, postId, data);
        return data;
    }

    function execute(address feed, uint256 postId, bytes calldata data) external override returns (bytes memory) {
        (address graph, address referrer, address collector) = abi.decode(data, (address, address, address));

        _validateAndStoreCollect(collector, graph, feed, postId);

        _processCollect(referrer, collector, feed, postId);

        emit Lens_PostAction_Executed(feed, postId, data);
        return data;
    }

    function getBasePublicationCollectData(address feed, uint256 postId)
        external
        view
        returns (BaseCollectActionExecuteData memory)
    {
        return $collectDataStorage().collectData[feed][postId];
    }

    function _validateSender(address sender, address feed, uint256 postId) internal virtual {
        if (sender != IFeed(feed).getPostAuthor(postId)) {
            revert("Sender is not the author");
        }
    }

    function _validateBaseConfigureData(BaseCollectActionConfigureData memory baseConfigData) internal virtual {
        // validate fees are less than 10000
        uint256 totalFees = 0;
        for (uint256 i = 0; i < baseConfigData.fees.length; i++) {
            totalFees += baseConfigData.fees[i].fee;
        }
        totalFees += baseConfigData.referralFee;
        if (totalFees > BPS_MAX || baseConfigData.endTimestamp != 0 && baseConfigData.endTimestamp < block.timestamp) {
            revert("Invalid params");
        }
    }

    function _storeBaseConfigureData(address feed, uint256 postId, BaseCollectActionConfigureData memory baseConfigData)
        internal
        virtual
    {
        $collectDataStorage().collectData[feed][postId] = BaseCollectActionExecuteData({
            amount: baseConfigData.amount,
            collectLimit: baseConfigData.collectLimit,
            currency: baseConfigData.currency,
            recipient: baseConfigData.recipient,
            referralFee: baseConfigData.referralFee,
            followerOnly: baseConfigData.followerOnly,
            endTimestamp: baseConfigData.endTimestamp,
            fees: baseConfigData.fees,
            currentCollects: 0
        });
    }

    function _validateAndStoreCollect(address collector, address graph, address feed, uint256 postId)
        internal
        virtual
    {
        BaseCollectActionExecuteData storage data = $collectDataStorage().collectData[feed][postId];
        data.currentCollects++;

        if (data.followerOnly && !IGraph(graph).isFollowing(collector, IFeed(feed).getPostAuthor(postId))) {
            revert("Collector is not following the author");
        }

        if (data.collectLimit != 0 && data.currentCollects > data.collectLimit) {
            revert("Collect limit exceeded");
        }

        if (data.endTimestamp != 0 && block.timestamp > data.endTimestamp) {
            revert("Collect expired");
        }
    }

    function _processCollect(address referrer, address collector, address feed, uint256 postId) internal virtual {
        BaseCollectActionExecuteData storage data = $collectDataStorage().collectData[feed][postId];
        uint256 amount = data.amount;
        address currency = data.currency;
        address recipient = data.recipient;
        CollectFee[] memory fees = data.fees;

        uint256 adjustedAmountAfterFees = _transferToFeeCollectors(currency, collector, amount, fees);

        if (referrer != collector) {
            uint256 referralAmount = (adjustedAmountAfterFees * data.referralFee) / BPS_MAX;
            adjustedAmountAfterFees -= _transferToRecipient(currency, collector, referrer, referralAmount);
        }

        _transferToRecipient(currency, collector, recipient, adjustedAmountAfterFees);
    }

    function _transferToRecipient(address currency, address collector, address recipient, uint256 amount)
        internal
        virtual
        returns (uint256)
    {
        if (amount > 0) {
            IERC20(currency).safeTransferFrom(collector, recipient, amount);
        }

        return amount;
    }

    function _transferToFeeCollectors(address currency, address collector, uint256 amount, CollectFee[] memory fees)
        internal
        virtual
        returns (uint256)
    {
        uint256 adjustedAmount = amount;

        for (uint256 i = 0; i < fees.length; i++) {
            uint256 feeAmount = (amount * fees[i].fee) / BPS_MAX;
            if (feeAmount > 0) {
                _transferToRecipient(currency, collector, fees[i].collector, feeAmount);
            }
            adjustedAmount -= feeAmount;
        }

        return adjustedAmount;
    }
}
