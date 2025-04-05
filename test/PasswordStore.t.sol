// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {PasswordStore} from "../src/PasswordStore.sol";
import {DeployPasswordStore} from "../script/DeployPasswordStore.s.sol";

contract PasswordStoreTest is Test {
    PasswordStore public passwordStore;
    DeployPasswordStore public deployer;
    address public owner;

    function setUp() public {
        // Create a new instance of the DeployPasswordStore contract
        deployer = new DeployPasswordStore();
        // Deploy a new PasswordStore contract using the deployer and store its address
        passwordStore = deployer.run();
        // msg.sender here is the address of the test contract (PasswordStoreTest)
        // We store it in owner variable so we can use vm.startPrank(owner) later
        
        owner = msg.sender;
    }

    function test_owner_can_set_password() public {
        // vm.startPrank() is a Foundry cheatcode that lets us simulate transactions 
        // as if they were sent from a specific address (in this case, the owner)
        vm.startPrank(owner);
        string memory expectedPassword = "myNewPassword";
        passwordStore.setPassword(expectedPassword);
        string memory actualPassword = passwordStore.getPassword();
        assertEq(actualPassword, expectedPassword);
    }

    function test_non_owner_reading_password_reverts() public {
        // Start simulating transactions from a non-owner address (address(1))
        vm.startPrank(address(1));

        // PasswordStore__NotOwner.selector is the first 4 bytes of the keccak256 hash
        // of the custom error signature "PasswordStore__NotOwner()". When the contract reverts
        // with this error, these bytes are included in the revert data to identify which error occurred
        vm.expectRevert(PasswordStore.PasswordStore__NotOwner.selector);
        // Try to read the password as a non-owner, which should fail
        passwordStore.getPassword();
    }

    function test_anyone_can_set_password(address randomAddress) public {
        vm.assume(randomAddress != owner);
        vm.prank(randomAddress);
        string memory expectedPassword = "Alhamdulillah Again";
        passwordStore.setPassword(expectedPassword);

        vm.prank(owner);
        string memory actualPassword = passwordStore.getPassword();
        assertEq(actualPassword, expectedPassword);
    }
}
