// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccessControl} from "./../primitives/access-control/IAccessControl.sol";
import {Username} from "./../primitives/username/Username.sol";
import {OwnerOnlyAccessControl} from "./../primitives/access-control/OwnerOnlyAccessControl.sol";
import {RuleConfiguration} from "./../types/Types.sol";

contract UsernameFactory {
    event Lens_UsernameFactory_Deployment(address indexed username);

    IAccessControl internal immutable _factoryOwnedAccessControl;

    constructor() {
        _factoryOwnedAccessControl = new OwnerOnlyAccessControl({owner: address(this)});
    }

    function deploy(
        string memory namespace,
        string memory metadataURI,
        IAccessControl accessControl,
        RuleConfiguration[] calldata rules
    ) external returns (address) {
        Username username = new Username(namespace, metadataURI, _factoryOwnedAccessControl);
        username.addUsernameRules(rules);
        username.setAccessControl(accessControl);
        emit Lens_UsernameFactory_Deployment(address(username));
        return address(username);
    }
}
