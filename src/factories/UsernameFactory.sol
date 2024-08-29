// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccessControl} from "./../primitives/access-control/IAccessControl.sol";
import {Username} from "./../primitives/username/Username.sol";
import {IUsernameRule} from "./../primitives/username/IUsernameRule.sol";
import {OwnerOnlyAccessControl} from "./../primitives/access-control/OwnerOnlyAccessControl.sol";
import {UsernameRuleCombinator} from "./../primitives/username/UsernameRuleCombinator.sol";

contract UsernameFactory {
    IAccessControl internal _accessControl; // TODO: Replace these storages with Core.$storage() pattern
    IAccessControl internal immutable _factoryOwnedAccessControl;
    // address internal _usernameImplementation; // We do not need this unless we Clone and we want to change the impl

    event UsernamePrimitiveCreated(
        address indexed usernameInstance,
        string namespace,
        IAccessControl accessControl,
        IUsernameRule rules,
        bytes rulesInitializationData
    );

    uint256 constant CHANGE_ACCESS_CONTROL_RID =
        uint256(keccak256("CHANGE_ACCESS_CONTROL"));
    uint256 constant DEPLOY_USERNAME_RID =
        uint256(keccak256("DEPLOY_USERNAME"));

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
        _factoryOwnedAccessControl = new OwnerOnlyAccessControl({
            owner: address(this)
        });
    }

    /*
        TODO:
        - Add Implementation address for the usernamePrimitive (changable with AccessControl)
        - Add Upgradeable pattern (best - Upgradeable Beacon Proxy, but we can have several)
          Support different upgradability flavours:
          * Immutable
          * Simple Upgradeable (TransparentUpgradeableProxy) (admin can upgrade to whatever he desires)
          * Beacon Proxy with opt-out
          * Beacon Proxy with Optional opt-out
          * ??? with Beacon
        - Add _accessControl (IAccessControl) to the constructor (and use in all of the above)

        - [Later] Add Payment to deploying UsernamePrimitive (controllable with AccessControl, skippable with AccessControl)
    */
    function deploy__Immutable_NoRules(
        string memory namespace,
        IAccessControl accessControl
    ) external returns (address) {
        require(
            IAccessControl(_accessControl).hasAccess({
                account: msg.sender,
                resourceLocation: address(this),
                resourceId: DEPLOY_USERNAME_RID
            })
        ); // msg.sender must have permissions to deploy
        address usernameInstance = address(
            new Username(namespace, accessControl)
        );
        return usernameInstance;
    }

    function deploy__Immutable_WithRules(
        string memory namespace,
        IAccessControl accessControl,
        bytes calldata rulesInitializationData
    ) external returns (address) {
        require(
            IAccessControl(_accessControl).hasAccess({
                account: msg.sender,
                resourceLocation: address(this),
                resourceId: DEPLOY_USERNAME_RID
            })
        ); // msg.sender must have permissions to deploy
        Username usernameInstance = new Username(
            namespace,
            _factoryOwnedAccessControl
        );

        IUsernameRule rulesInstance = new UsernameRuleCombinator();
        rulesInstance.configure(rulesInitializationData);

        usernameInstance.setUsernameRules(rulesInstance);

        usernameInstance.setAccessControl(accessControl);

        emit UsernamePrimitiveCreated(
            address(usernameInstance),
            namespace,
            accessControl,
            rulesInstance,
            rulesInitializationData
        );
        return address(usernameInstance);
    }
}
