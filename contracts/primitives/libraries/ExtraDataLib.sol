// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {DataElement, DataElementValue} from "../../types/Types.sol";

library ExtraDataLib {
    function set(
        mapping(bytes32 => DataElementValue) storage _extraDataStorage,
        DataElement calldata extraDataElementToSet
    ) internal returns (bool) {
        return _setExtraDataElement(_extraDataStorage, extraDataElementToSet);
    }

    function remove(mapping(bytes32 => DataElementValue) storage _extraDataStorage, bytes32 extraDataKeyToRemove)
        internal
    {
        return _removeExtraDataElement(_extraDataStorage, extraDataKeyToRemove);
    }

    function set(mapping(bytes32 => DataElementValue) storage _extraDataStorage, DataElement[] calldata extraDataToSet)
        internal
        returns (bool[] memory)
    {
        return _setExtraData(_extraDataStorage, extraDataToSet);
    }

    function remove(
        mapping(bytes32 => DataElementValue) storage _extraDataStorage,
        bytes32[] calldata extraDataKeysToRemove
    ) internal {
        return _removeExtraData(_extraDataStorage, extraDataKeysToRemove);
    }

    function _setExtraDataElement(
        mapping(bytes32 => DataElementValue) storage _extraDataStorage,
        DataElement calldata extraDataElementToSet
    ) internal returns (bool) {
        bool wasPreviousValueSet = _extraDataStorage[extraDataElementToSet.key].isSet;
        _extraDataStorage[extraDataElementToSet.key] =
            DataElementValue(true, uint80(block.timestamp), extraDataElementToSet.value);
        return wasPreviousValueSet;
    }

    function _setExtraData(
        mapping(bytes32 => DataElementValue) storage _extraDataStorage,
        DataElement[] calldata extraDataToSet
    ) internal returns (bool[] memory) {
        bool[] memory werePreviousValuesSet = new bool[](extraDataToSet.length);
        for (uint256 i = 0; i < extraDataToSet.length; i++) {
            werePreviousValuesSet[i] = _setExtraDataElement(_extraDataStorage, extraDataToSet[i]);
        }
        return werePreviousValuesSet;
    }

    function _removeExtraDataElement(
        mapping(bytes32 => DataElementValue) storage _extraDataStorage,
        bytes32 extraDataKeyToRemove
    ) internal {
        _extraDataStorage[extraDataKeyToRemove] = DataElementValue(false, uint80(block.timestamp), "");
    }

    function _removeExtraData(
        mapping(bytes32 => DataElementValue) storage _extraDataStorage,
        bytes32[] calldata extraDataKeysToRemove
    ) internal {
        for (uint256 i = 0; i < extraDataKeysToRemove.length; i++) {
            _removeExtraDataElement(_extraDataStorage, extraDataKeysToRemove[i]);
        }
    }
}
