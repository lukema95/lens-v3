// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AccountFactory {
    event Lens_Factory_AccountCreated(address account, address createdBy);
}

contract Account {
    event Lens_Account_ManagerAdded(address manager); // TODO: We might have AccessControl on our Managers
    event Lens_Account_ManagerRemoved(address manager);
}
