pragma solidity 0.8.17;

import "forge-std/Test.sol";
import {LensFactory} from "../../contracts/factories/LensFactory.sol";
import {AccountFactory} from "../../contracts/factories/AccountFactory.sol";
import {AppFactory} from "../../contracts/factories/AppFactory.sol";
import {GroupFactory} from "../../contracts/factories/GroupFactory.sol";
import {FeedFactory} from "../../contracts/factories/FeedFactory.sol";
import {GraphFactory} from "../../contracts/factories/GraphFactory.sol";
import {UsernameFactory} from "../../contracts/factories/UsernameFactory.sol";
import {Username} from "../../contracts/primitives/username/Username.sol";
import {RuleConfiguration, DataElement, SourceStamp, RuleExecutionData} from "../../contracts/types/Types.sol";
import {AccountManagerPermissions} from "../../contracts/primitives/account/Account.sol";

contract LensFactoryTest is Test {
    LensFactory lensFactory;
    Username username;

    function setUp() public {
        lensFactory = new LensFactory({
            accountFactory: new AccountFactory(),
            appFactory: new AppFactory(),
            groupFactory: new GroupFactory(),
            feedFactory: new FeedFactory(),
            graphFactory: new GraphFactory(),
            usernameFactory: new UsernameFactory()
        });

        username = Username(
            lensFactory.deployUsername({
                namespace: "bitcoin",
                metadataURI: "satoshi://nakamoto",
                owner: address(this),
                admins: new address[](0),
                rules: new RuleConfiguration[](0),
                extraData: new DataElement[](0),
                nftName: "Bitcoin",
                nftSymbol: "BTC"
            })
        );
    }

    function testItYeahYeahWhoohoooo() public {
        lensFactory.createAccountWithUsernameFree({
            metadataURI: "someMetadataURI",
            owner: address(this),
            accountManagers: new address[](0),
            accountManagersPermissions: new AccountManagerPermissions[](0),
            usernamePrimitiveAddress: address(username),
            username: "myTestUsername",
            createUsernameData: RuleExecutionData(new bytes[](0), new bytes[](0)),
            assignUsernameData: RuleExecutionData(new bytes[](0), new bytes[](0)),
            accountCreationSourceStamp: SourceStamp(address(0), 0, 0, ""),
            assignUsernameSourceStamp: SourceStamp(address(0), 0, 0, ""),
            createUsernameSourceStamp: SourceStamp(address(0), 0, 0, "")
        });
    }
}
