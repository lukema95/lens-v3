// SPDX-License-Identifier: UNLICENSED
// Copyright (C) 2024 Lens Labs. All Rights Reserved.
pragma solidity ^0.8.17;

struct DataElement {
    bytes32 key;
    bytes value;
}

struct DataElementValue {
    bool isSet;
    uint80 lastUpdatedTimestamp;
    bytes value;
}

struct RuleConfiguration {
    address ruleAddress;
    bytes configData;
    bool isRequired;
}

struct RuleExecutionData {
    bytes[] dataForRequiredRules;
    bytes[] dataForAnyOfRules;
}

struct SourceStamp {
    address source;
    uint256 nonce;
    uint256 deadline;
    bytes signature;
}
