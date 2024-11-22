// SPDX-License-Identifier: UNLICENSED
// Copyright (C) 2024 Lens Labs. All Rights Reserved.
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import {IAccessControl} from "@core/interfaces/IAccessControl.sol";
import {OwnerAdminOnlyAccessControl} from "@dashboard/access/OwnerAdminOnlyAccessControl.sol";
import {IUsername} from "@core/interfaces/IUsername.sol";
import {Username} from "@core/primitives/Username/Username.sol";
import {LensUsernameTokenURIProvider} from "@core/primitives/Username/LensUsernameTokenURIProvider.sol";
import "../helpers/TypeHelpers.sol";

contract UsernameTest is Test {
    IAccessControl accessControl;
    IUsername username;

    address account = makeAddr("ACCOUNT");

    function setUp() public {
        accessControl = new OwnerAdminOnlyAccessControl(address(this));
        username = new Username({
            namespace: "bitcoin",
            metadataURI: "satoshi://nakamoto",
            accessControl: accessControl,
            nftName: "Bitcoin",
            nftSymbol: "BTC",
            tokenURIProvider: new LensUsernameTokenURIProvider()
        });
    }

    function testCreateAssignUnassignDelete() public {
        string memory localName = "satoshi";

        vm.prank(account);
        username.createUsername(account, localName, _emptyExecutionData(), _emptySourceStamp());

        vm.prank(account);
        username.assignUsername(account, localName, _emptyExecutionData(), _emptySourceStamp());

        vm.prank(account);
        username.unassignUsername(localName, _emptySourceStamp());

        vm.prank(account);
        username.removeUsername(localName, _emptySourceStamp());
    }
}
