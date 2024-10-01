// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccessControl} from "./../primitives/access-control/IAccessControl.sol";
import {InitialProperties, App} from "./../primitives/app/App.sol";
import {DataElement} from "./../types/Types.sol";

contract AppFactory {
    event Lens_AppFactory_Deployment(address indexed app);

    function deploy(IAccessControl accessControl, InitialProperties calldata initialProperties)
        external
        returns (address)
    {
        App app = new App(accessControl, initialProperties);
        emit Lens_AppFactory_Deployment(address(app));
        return address(app);
    }
}
