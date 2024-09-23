// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import {UsernameCore as Core} from "./UsernameCore.sol";
// import {IUsernameRule} from "./IUsernameRule.sol";
// import {IUsername} from "./IUsername.sol";
// import {IAccessControl} from "./../access-control/IAccessControl.sol";
// import {DataElement} from "./../../types/Types.sol";
// import {RuleBased} from "./../base/RuleBased.sol";
// import {AccessControlled} from "./../base/AccessControlled.sol";
// import {IAccessControl} from "./../access-control/IAccessControl.sol";
// import {RuleConfiguration} from "./../../types/Types.sol";

// contract Username is IUsername, RuleBased, AccessControlled {
//     uint256 constant SET_EXTRA_DATA_RID = uint256(keccak256("SET_EXTRA_DATA"));
//     // TODO: Do we want more granular resources here? Like add/update/remove RIDs? Or are we OK with the multi-purpose?
//     uint256 constant SET_RULES_RID = uint256(keccak256("SET_RULES"));

//     // TODO: This will be a mandatory rule now
//     // // Storage fields and structs
//     // struct LengthRestriction {
//     //     uint8 min;
//     //     uint8 max;
//     // }

//     constructor(string memory namespace, IAccessControl accessControl)
//         RuleBased(bytes32(0))
//         AccessControlled(accessControl)
//     {
//         Core.$storage().namespace = namespace;
//     }

//     // Access Controlled functions

//     function addUsernameRules(RuleConfiguration[] calldata ruleConfigurations) external {
//         _requireAccess(SET_RULES_RID);
//         for (uint256 i = 0; i < ruleConfigurations.length; i++) {
//             _addRule(ruleConfigurations[i]);
//             emit Lens_Username_RuleAdded(
//                 ruleConfigurations[i].ruleAddress, ruleConfigurations[i].configData, ruleConfigurations[i].isRequired
//             );
//         }
//     }

//     function updateUsernameRules(RuleConfiguration[] calldata ruleConfigurations) external {
//         _requireAccess(SET_RULES_RID);
//         for (uint256 i = 0; i < ruleConfigurations.length; i++) {
//             _updateRule(ruleConfigurations[i]);
//             emit Lens_Username_RuleUpdated(
//                 ruleConfigurations[i].ruleAddress, ruleConfigurations[i].configData, ruleConfigurations[i].isRequired
//             );
//         }
//     }

//     function removeUsernameRules(address[] calldata rules) external {
//         _requireAccess(SET_RULES_RID);
//         for (uint256 i = 0; i < rules.length; i++) {
//             _removeRule(rules[i]);
//             emit Lens_Username_RuleRemoved(rules[i]);
//         }
//     }

//     // Permissionless functions

//     function registerUsername(address account, string memory username, bytes calldata data) external {
//         require(msg.sender == account); // msg.sender must be the account
//         // IUsernameRule(Core.$storage().usernameRules).processRegistering(msg.sender, account, username, data);
//         // _validateUsernameLength(username);
//         Core._registerUsername(account, username);
//         emit Lens_Username_Registered(username, account, data);
//     }

//     // TODO: Decide if it worth to have a "before/after" hook for the rules, or if we are covered just with the "before"
//     // Think about CEI pattern and if we are OK with the "before", because it looks more like CIE than CEI.
//     // function registerUsername(address account, string memory username, bytes calldata data) external {
//     //     require(msg.sender == account); // msg.sender must be the account
//     //     IUsernameRule(Core.$storage().usernameRules).beforeRegistering(msg.sender, account, username, data);
//     //     Core._registerUsername(account, username);
//     //     IUsernameRule(Core.$storage().usernameRules).afterRegistering(msg.sender, account, username, data);
//     //     emit Lens_Username_Registered(username, account, data);
//     // }

//     function unregisterUsername(string memory username, bytes calldata data) external {
//         address account = Core.$storage().usernameToAccount[username];
//         require(msg.sender == account); // msg.sender must be the account
//         // IUsernameRule(Core.$storage().usernameRules).processUnregistering(msg.sender, account, username, data);
//         Core._unregisterUsername(username);
//         emit Lens_Username_Unregistered(username, account, data);
//     }

//     function setExtraData(DataElement[] calldata extraDataToSet) external override {
//         // Core.$storage().accessControl.requireAccess(msg.sender, SET_EXTRA_DATA_RID);
//         Core._setExtraData(extraDataToSet);
//         for (uint256 i = 0; i < extraDataToSet.length; i++) {
//             emit Lens_Username_ExtraDataSet(extraDataToSet[i].key, extraDataToSet[i].value, extraDataToSet[i].value);
//         }
//     }

//     // Internal

//     // function _validateUsernameLength(string memory username) internal pure {
//     //     // TODO: Add the RIDs for skipping length restrictions.
//     //     LengthRestriction memory lengthRestriction = $lengthRestriction();
//     //     uint256 usernameLength = bytes(username).length;
//     //     if (lengthRestriction.min != 0) {
//     //         require(usernameLength >= lengthRestriction.min, "Username: too short");
//     //     }
//     //     if (lengthRestriction.max != 0) {
//     //         // TODO: If no restriction, should be max(uint8), not unlimited! - API will be like that
//     //         require(usernameLength <= lengthRestriction.max, "Username: too long");
//     //     }
//     // }

//     // Storage utility & helper functions

//     // // keccak256('lens.username.storage.length.restriction')
//     // bytes32 constant LENGTH_RESTRICTION_STORAGE_SLOT =
//     //     0x2d828a00137871809f1a4bee7ddd78f42d45a25fe20299ceaf25638343e83134;

//     // function $lengthRestriction() internal pure returns (LengthRestriction storage _lengthRestriction) {
//     //     assembly {
//     //         _lengthRestriction.slot := LENGTH_RESTRICTION_STORAGE_SLOT
//     //     }
//     // }

//     // Getters

//     function usernameOf(address user) external view returns (string memory) {
//         return Core.$storage().accountToUsername[user];
//     }

//     function accountOf(string memory name) external view returns (address) {
//         return Core.$storage().usernameToAccount[name];
//     }

//     function getNamespace() external view returns (string memory) {
//         return Core.$storage().namespace;
//     }

//     function getExtraData(bytes32 key) external view override returns (bytes memory) {
//         return Core.$storage().extraData[key];
//     }
// }
