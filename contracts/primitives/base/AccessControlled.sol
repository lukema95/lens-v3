// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccessControl} from "./../access-control/IAccessControl.sol";
import {AccessControlLib} from "./../libraries/AccessControlLib.sol";

contract AccessControlled {
    using AccessControlLib for IAccessControl;
    using AccessControlLib for address;

    uint256 constant SET_ACCESS_CONTROL_RID = uint256(keccak256("SET_ACCESS_CONTROL"));

    struct AccessControlledStorage {
        address accessControl;
    }

    // keccak256('lens.access.controlled.storage')
    bytes32 constant ACCESS_CONTROLLED_STORAGE_SLOT = 0x9211c0302e22d62530da4939528366f76a6ad7e8fc8b35b47780fadbea21baac;

    function $accessControlledStorage() private pure returns (AccessControlledStorage storage _storage) {
        assembly {
            _storage.slot := ACCESS_CONTROLLED_STORAGE_SLOT
        }
    }

    constructor(IAccessControl accessControl) {
        accessControl.verifyHasAccessFunction();
        _setAccessControl(address(accessControl));
    }

    modifier requireAccess(uint256 resourceId) {
        _requireAccess(msg.sender, resourceId);
        _;
    }

    function _requireAccess(uint256 resourceId) internal view {
        _requireAccess(msg.sender, resourceId);
    }

    function _requireAccess(address account, uint256 resourceId) internal view {
        _accessControl().requireAccess(account, resourceId);
    }

    // Access Controlled Functions
    function setAccessControl(IAccessControl newAccessControl) external {
        // TODO: This is a 1-step operation, while some of our AC owner transfers are a 2-step, or even 3-step operations.
        _accessControl().requireAccess(msg.sender, SET_ACCESS_CONTROL_RID);
        newAccessControl.verifyHasAccessFunction();
        _setAccessControl(address(newAccessControl));
    }

    // Internal functions

    function _accessControl() internal view returns (IAccessControl) {
        return IAccessControl($accessControlledStorage().accessControl);
    }

    function _setAccessControl(address newAccessControl) internal {
        $accessControlledStorage().accessControl = newAccessControl;
    }

    // Getters

    function getAccessControl() external view returns (IAccessControl) {
        return _accessControl();
    }
}
