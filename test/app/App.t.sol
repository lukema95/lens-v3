// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import {App, AppInitialProperties} from "../../contracts/primitives/app/App.sol";
import {IAccessControl} from "../../contracts/primitives/access-control/IAccessControl.sol";
import {DataElement} from "../../contracts/types/Types.sol";
import {OwnerAdminOnlyAccessControl} from "../../contracts/primitives/access-control/OwnerAdminOnlyAccessControl.sol";

// struct AppInitialProperties {
//     address graph;
//     address[] feeds;
//     address username;
//     address[] groups;
//     address defaultFeed;
//     address[] signers;
//     address paymaster;
//     address treasury;
// }

// --- constructor args ---
// string memory metadataURI,
// bool isSourceStampVerificationEnabled,
// IAccessControl accessControl,
// AppInitialProperties memory initialProps,
// DataElement[] memory extraData

contract AppTest is Test {
    IAccessControl accessControl;
    App app;

    function setUp() public {
        accessControl = new OwnerAdminOnlyAccessControl(address(this));
    }

    function testCanInitializeWithValues() public {
        app = new App({
            metadataURI: "",
            isSourceStampVerificationEnabled: false,
            accessControl: IAccessControl(accessControl),
            initialProps: AppInitialProperties({
                graph: address(0x01),
                feeds: new address[](0),
                username: address(0x02),
                groups: new address[](0),
                defaultFeed: address(0),
                signers: new address[](0),
                paymaster: address(0x3),
                treasury: address(0x4)
            }),
            extraData: new DataElement[](0)
        });
    }

    function testCanInitializeEmpty() public {
        app = new App({
            metadataURI: "",
            isSourceStampVerificationEnabled: false,
            accessControl: IAccessControl(accessControl),
            initialProps: AppInitialProperties({
                graph: address(0),
                feeds: new address[](0),
                username: address(0),
                groups: new address[](0),
                defaultFeed: address(0),
                signers: new address[](0),
                paymaster: address(0),
                treasury: address(0)
            }),
            extraData: new DataElement[](0)
        });
    }
}
