// SPDX-License-Identifier: UNLICENSED
// Copyright (C) 2024 Lens Labs. All Rights Reserved.
pragma solidity ^0.8.17;

import {DataElement, DataElementValue} from "./../types/Types.sol";

library ExtraDataLib {
    function set(
        mapping(bytes32 => DataElementValue) storage _extraDataStorage,
        DataElement memory extraDataElementToSet
    ) internal returns (bool) {
        return _setExtraDataElement(_extraDataStorage, extraDataElementToSet);
    }

    function remove(mapping(bytes32 => DataElementValue) storage _extraDataStorage, bytes32 extraDataKeyToRemove)
        internal
        returns (bool)
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
    ) internal returns (bool) {
        return _removeExtraData(_extraDataStorage, extraDataKeysToRemove);
    }

    function _setExtraDataElement(
        mapping(bytes32 => DataElementValue) storage _extraDataStorage,
        DataElement memory extraDataElementToSet
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
    ) internal returns (bool) {
        bool wasValueSet = _extraDataStorage[extraDataKeyToRemove].isSet;
        _extraDataStorage[extraDataKeyToRemove] = DataElementValue(false, uint80(block.timestamp), "");
        return wasValueSet;
    }

    function _removeExtraData(
        mapping(bytes32 => DataElementValue) storage _extraDataStorage,
        bytes32[] calldata extraDataKeysToRemove
    ) internal returns (bool) {
        bool wereAllValuesSet = true;
        for (uint256 i = 0; i < extraDataKeysToRemove.length; i++) {
            wereAllValuesSet = wereAllValuesSet && _removeExtraDataElement(_extraDataStorage, extraDataKeysToRemove[i]);
        }
        return wereAllValuesSet;
    }
}
