/*
    What do we want?

    - We want some AccessControl system that will have multiple roles (like Owner, Admin, Moderator, etc)
        * The roles might even be fixed at the start to OWNER/ADMIN/MODERATOR/OTHER for example
    - In the default case, we want different roles to have different permissions. For example:
        NONE, /////// 0 - No special control
        MODERATOR, // 1 - Soft control
        ADMIN, ////// 2 - Hard control (+Soft Control)
        OWNER /////// 3 - Full control (+Hard Control +Soft Control)
    - Question #1: Who can call "setRole"?
        * In the default case, OWNER can set all the roles, including changing the OWNER itself
        * ADMIN can only set MODERATORS
        * MODERATOR can't set any roles
        * So the answer is: it's downward only (strict <), except for owner, who can also set himself (so its <=)
    - Question #2: Where this hierarchy logic is set?
        * In the AccessControl flavor implementation
        * So, for the default case - in this AccessControl contract (not in the Rule)
    - Question #3: Who can call "setAccess"?
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAccessControl_WithoutScaryTrooleans {
    // Role functions
    function setRole(address account, uint256 roleId) external;

    function hasRole(address account, uint256 roleId) external view returns (bool);

    function getRole(address account) external view returns (uint256);

    // Resource access permissions functions - Global
    function clearAccess(uint256 roleId, uint256 resourceId) external;

    function grantAccess(uint256 roleId, uint256 resourceId) external;

    function denyAccess(uint256 roleId, uint256 resourceId) external;

    // Resource access permissions functions - Local (location is address based)
    function clearAccess(uint256 roleId, address resourceLocation, uint256 resourceId) external;

    function grantAccess(uint256 roleId, address resourceLocation, uint256 resourceId) external;

    function denyAccess(uint256 roleId, address resourceLocation, uint256 resourceId) external;

    function hasAccess(uint256 roleId, address resourceLocation, uint256 resource) external view returns (bool);

    function hasAccess(address account, address resourceLocation, uint256 resource) external view returns (bool);

    function hasAccess(uint256 roleId, uint256 resource) external view returns (bool);

    function hasAccess(address account, uint256 resource) external view returns (bool);
}

contract InterfaceVersioning {
    function setRole(address account, uint256 roleId, bytes memory roleData) external {
        // V1: We encode the roleData as a tuple - (uint256, address)
        (uint256 that, address andThat) = abi.decode(roleData, (uint256, address));

        (, bytes memory innerData) = abi.decode(roleData, (uint8, bytes));
        (uint256 thing, address otherThing) = abi.decode(innerData, (uint256, address));

        // Then we decide we need to add a different thing to the roleData in some case:
        // (uint256, address, bool)
        // (uint256 that, address andThat, bool anotherThing) = abi.decode(roleData, (uint256, address, bool));

        // Then how do you code a contract that supports both?

        // V1 of the AccessControl only supports this:
        // (bool canGrant, bool canDelegate)

        // In V2 of AccessControl we want to support several modes:
        // Simple V1 mode: (bool canGrant, bool canDelegate)
        // Time-limited mode: (bool canGrant, bool canDelegate, uint256 endTime)
        // Function-limited mode: (bool canGrant, bool canDelegate, bytes4[] allowedFunctions)

        // How do we encode and decode ABI roleData to support different modes?
        // Is it (MODE, innerData)?

        // Or maybe we can make ALL our interfaces different flavored.
        // We can do (MODE, innerData) where MODE is a uint8 that represents the mode/version/flavor and innerData is encoded.
    }
}

interface IAccessControl {
    enum AccessPermission {
        UNDEFINED,
        GRANTED,
        DENIED
    }

    // Role functions
    function setRole(address account, uint256 roleId) external;

    function hasRole(address account, uint256 roleId) external view returns (bool);

    function getRole(address account) external view returns (uint256);

    // Resource access permissions functions - Global
    function setAccess(uint256 roleId, uint256 resourceId, AccessPermission accessPermission) external;

    // Resource access permissions functions - Local (location is address based)
    function setAccess(
        uint256 roleId,
        address resourceLocation,
        uint256 resourceId,
        AccessPermission accessPermission
    ) external;

    function hasAccess(uint256 roleId, address resourceLocation, uint256 resourceId) external view returns (bool);

    function hasAccess(address account, address resourceLocation, uint256 resourceId) external view returns (bool);

    // Internal state views can be added to implementation if needed:
    // function _queryGlobalAccessStorage(uint256 roleId, uint256 resourceId) external view returns (AccessPermission);

    // function getAccess(address account, uint256 resourceId) external view returns (AccessPermission);

    // function getLocalAccessState(
    //     uint256 roleId,
    //     address resourceLocation,
    //     uint256 resourceId
    // ) external view returns (AccessPermission);

    // function getAccess(
    //     address account,
    //     address resourceLocation,
    //     uint256 resourceId
    // ) external view returns (AccessPermission);
}

// TODO: Add custom bytes data param to set role and permission functions!
// TODO: Maybe the interface should just be the two `hasAccess` functions. The rest is more of an implementation detail.
interface IAccessControl_Simplified {
    // TODO: If yes - do we need hasRole, getRole?
    // TODO: If yes - do we need setRole then too?
    function hasRole(address account, uint256 roleId) external view returns (bool);

    function getRole(address account) external view returns (uint256);

    function hasAccess(uint256 roleId, address resourceLocation, uint256 resourceId) external view returns (bool);

    function hasAccess(address account, address resourceLocation, uint256 resourceId) external view returns (bool);
}

// contract SomeRule {
//     bytes32 _canSkipPaymentResourceId; // It can be equals to `keccack(address(this), 'CAN_SKIP_PAYMENT')` or `keccak('CAN_SKIP_PAYMENT')`

//     // Say we have both, stored at AccessControl contract:
//     // keccak(CAN_SKIP_PAYMENT) is global one
//     // keccak(address+CANSKIP_PAYMENT) is a local rule one

//     function configure(bytes32 canSkipPaymentResourceId) {
//         _canSkipPaymentResourceId = canSkipPaymentResourceId;
//     }

//     function doSomeStuffThatHasAPaymentRestrictionRule() internal {
//         // resourceId = keccak256(address(this), 'CAN_SKIP_PAYMENT');
//         // resourceId = uint256(keccak256('CAN_SKIP_PAYMENT');

//         if (ac.hasAccess(LOCAL_ONE).isSet()) {
//             // check this
//         } else if (ac.hasAccess(GLOBAL_ONE).isSet()) {
//             // check this
//         }

//         resourceId = _canSkipPaymentResourceId;

//         // ac.setAccess(roleId, uint256(keccak256('CAN_SKIP_PAYMENT')), true);

//         if (ac.hasAccess(msg.sender, resourceId)) {
//             // do something
//         }
//     }
// }

/*

This question does not have anything to do with Approaches that come later.

Question: Are there permissions that are "global" for all rules, or are they always rule-specific?
Or is there a way for this to be chosen each time. Like by default global, but this rule will have a specific isolated/custom setup.   

--

 Approach 1: (WE TAKE THIS ONE)
 -----------
 You call the AC directly, independently, to set the access permissions to the resources that you know that the rule will query/need.
 Then you set the rule, you pass the proper AC address to the rule, and that's it.

 Approach 2:
 -----------
 You configure the rule, and the rule calls the AC to set the permissions for its own resources.

---

Defining the approach and answering the question, we might know how resources are defined... hopefully :)

 */

/*

    What properties do we want a Rule to have? (from Permissions point of view)
    - Rule should be able to have specific rule-based resource permissions (canMint, canSkipThis, canWithdraw, etc)    
    - Rule should be able to know if an address has or has not the rights to do certain things (permissions mentioned above)
    
    * Should the rule be able to modify its own resource permissions from inside the rule?

*/

/*

    Complex scenario:

    1) 
    2) Only the owner can grant this permission to somebody
    3) Owner 
    
    
    ---

    1) Owner configures that Admins can manage everything about Moderators
    2) Owner has permissions to set Admins
    3) Admins can manage Moderator's permissions, so they give Moderators the permission to set Admins (oh shit!)
        * Admins cannot grant the canSetAdmin role to anyone if they don't have it themselves
    4) Now Moderators can set Admins, despite the Owner wanted this to be an Owner-only action

    WHO CAN GIVE PERMISSIONS??? Only the owner?

    Who can give roles, does not matter much, as long as we only allow to give "less-powerful" roles than yyo

    I see there are three modes of each permission:
    Alice might have:
        1) thePermissionItself (Alice canWithdraw)
        2) theRightToAssignThisPermissionToOthers (Alice can assign canWithdraw to Bob, but Bob cannot assign this to Charlie)
        3) theRightToGiveTheAssignmentRightToOthers (Alice can make Bob be able to assign canWithdraw to Charlie)

        For a permission we have:

1) The permission granted itself, so the ability to do something because of having this permission granted (e.g. canSkipPayment)
2) The permission to grant this permission to other roles (e.g. canGrantCanSkipPayment, which will allow to grant canSkipPayment to other roles)
3) The permission to grant the permission to grant the permission to other roles (e.g. canGrantCanGrantCanSkipPayment, which will allow to grant canGrantCanSkipPayment to other roles)

*/
