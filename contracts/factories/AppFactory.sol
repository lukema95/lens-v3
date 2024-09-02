// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccessControl} from "./../primitives/access-control/IAccessControl.sol";
import {InitialProperties, App} from "./../primitives/app/App.sol";
import {OwnerOnlyAccessControl} from "./../primitives/access-control/OwnerOnlyAccessControl.sol";

contract AppFactory {
    event Lens_AppFactory_NewAppInstance(
        address indexed appInstance, string namespace, IAccessControl accessControl, bytes rulesInitializationData
    );

    IAccessControl internal _accessControl; // TODO: Replace these storages with Core.$storage() pattern
    IAccessControl internal immutable _factoryOwnedAccessControl;
    // address internal _appImplementation; // We do not need this unless we Clone and we want to change the impl

    uint256 constant CHANGE_ACCESS_CONTROL_RID = uint256(keccak256("CHANGE_ACCESS_CONTROL"));
    uint256 constant DEPLOY_APP_RID = uint256(keccak256("DEPLOY_APP"));

    function setAccessControl(IAccessControl accessControl) external {
        require(
            IAccessControl(_accessControl).hasAccess({
                account: msg.sender,
                resourceLocation: address(this),
                resourceId: CHANGE_ACCESS_CONTROL_RID
            })
        ); // msg.sender must have permissions to change access control
        accessControl.hasAccess(address(0), address(0), 0); // We expect this to not panic.
        _accessControl = accessControl;
    }

    constructor(IAccessControl accessControl) {
        _accessControl = accessControl;
        _factoryOwnedAccessControl = new OwnerOnlyAccessControl({owner: address(this)});
    }

    /*
        TODO:
        - Add Implementation address for the appPrimitive (changable with AccessControl)
        - Add Upgradeable pattern (best - Upgradeable Beacon Proxy, but we can have several)
          Support different upgradability flavours:
          * Immutable
          * Simple Upgradeable (TransparentUpgradeableProxy) (admin can upgrade to whatever he desires)
          * Beacon Proxy with opt-out
          * Beacon Proxy with Optional opt-out
          * ??? with Beacon
        - Add _accessControl (IAccessControl) to the constructor (and use in all of the above)

        - [Later] Add Payment to deploying AppPrimitive (controllable with AccessControl, skippable with AccessControl)
    */
    /*
    TODO:
    - We need a msg.sender (aka deployer) in the event in the constructor - so we know if it's a factory or not
    - We need an actual deployer (msg.sender of the factory call) as the guy who is deploying through the factory (and pass it probably)
    - We need the referrals Josh mentioned in the Factory, so we know who referred the deployer
    */
    function deploy__Immutable_NoRules(
        IAccessControl accessControl,
        string calldata metadataURI,
        address treasury,
        InitialProperties calldata initialProperties
    ) external returns (address) {
        require(
            IAccessControl(_accessControl).hasAccess({
                account: msg.sender,
                resourceLocation: address(this),
                resourceId: DEPLOY_APP_RID
            })
        ); // msg.sender must have permissions to deploy
        address appInstance = address(new App(accessControl, metadataURI, treasury, initialProperties));
        emit Lens_AppFactory_NewAppInstance({
            appInstance: appInstance,
            namespace: metadataURI,
            accessControl: accessControl,
            rulesInitializationData: ""
        });
        return appInstance;
    }
}
