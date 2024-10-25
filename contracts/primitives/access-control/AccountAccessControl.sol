// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccessControl} from "./IAccessControl.sol";
import {Events} from "./../../types/Events.sol";
import {RoleBasedAccessControl} from "./RoleBasedAccessControl.sol";

contract AccountAccessControl is IAccessControl, RoleBasedAccessControl {
    constructor() {
        emit Events.Lens_Contract_Deployed(
            "access-control", "lens.access-control.account", "access-control", "lens.access-control.account"
        );
    }

    // TODO: Override role-granting function so only Account Manager role is allowed, along single Owner role.

    /**
     * For calling the contracts functions, we encode:
     *   permissionId ==> bytes4 function selector converted to uint256
     *
     * With this design, you should whitelist only the contracts and selectors you trust.
     *
     * If you want to allow spending, then you allow the `transfer` selector for the ERC20 token's address, etc.
     *
     * Another option if, we blacklist completely the ERC20 and ERC721 selectors, to avoid any draining of assets.
     */
    function hasAccess(address account, address contractAddress, uint256 permissionId)
        external
        view
        virtual
        override
        returns (bool)
    {
        return _getAccessForAllRoles(account, contractAddress, permissionId);
    }

    /*
      1)  Type: Scoped
         contract-address && permissionId != 0
      2)  Type: Scoped-all
         contract-address && permissionId == 0
      3)  Type: Global
         permissionId != 0
      4)  Type: Global-all
         permissionId == 0
    */
    function _getAccessForAllRoles(address account, address contractAddress, uint256 permissionId)
        internal
        view
        returns (bool)
    {
        if (_owner == account) {
            return true;
        } else {
            for (uint256 i = 0; i < _roles[account].length; i++) {
                if (_doesRoleHasAccess(_roles[account][i], contractAddress, permissionI) == Access.GRANTED) {
                    return true;
                }
            }
            return false;
        }
    }

    // Shouldn't this "permissionId == 0" only work as "*" for permissionId's <= bytes4.max ? 👀
    // Yes. And we can have the same thing, but with another mapping for the general keccak-based AccessControl.

    // < some bytes prefix > 0 0 0 0 0 0 0 0 . . . 0 < selector >

    // this means that...
    // < some bytes prefix > 0 0 0 0 0 0 0 0 . . . 0 0 0 0 0 0 0 0 ==> selector == 0 ==>
    // This means you have wildcard for the < some bytes prefix > strategy

    // You don't need to bring bytes data back, as long as your strategyPrefix is always a fixed length.

    // function _x(uint256 roleId, address contractAddress, uint256 permissionId) {
    //     if (permissionId has selectorStrategyPrefix) {
    //         Shift to remove the prefix.
    //         If all zero, then allowed
    //     }
    // }

    function _doesRoleHasAccess(uint256 roleId, address contractAddress, uint256 permissionId)
        internal
        view
        returns (Access)
    {
        if (_scopedSelectorAccess[_roles[account][i]][contractAddress][permissionId] == Access.DENIED) {
            return Access.DENIED;
        } else if (_scopedSelectorAccess[_roles[account][i]][contractAddress][permissionId] == Access.GRANTED) {
            return Access.GRANTED;
        } else if (_scopedSelectorAccess[_roles[account][i]][contractAddress][0] == Access.DENIED) {
            return Access.DENIED;
        } else if (_scopedSelectorAccess[_roles[account][i]][contractAddress][0] == Access.GRANTED) {
            return Access.GRANTED;
        } else if (_globalSelectorAccess[_roles[account][i]][permissionId] == Access.DENIED) {
            return Access.DENIED;
        } else if (_globalSelectorAccess[_roles[account][i]][permissionId] == Access.GRANTED) {
            return Access.GRANTED;
        }
        return _globalSelectorAccess[_roles[account][i]][0];
    }
}
