### [S-#] TITLE (Root Cause + Impact)
### [S-#] Storing the password on-chain makes it visible to anyone, and no longer private
### [H-1] Variables stored in storage on-chain are visible to anyone, no matter the solidity visibility keyword meaning the password is not actually a private passowrd

**Desription:**All data stored on-chain is visible to anyone, an dcan be read directly from the blockchain. The `PasswordStore::s_password` vriable is intended to be a private vriable and only accessed through the `PasswordStore::getPassword` function, which intended to be only called by the owner of the contract.

We show one such method of reading any data off-chain below

**Impact:**Anyone can read the private password, severly breaking the functionality of the protocol.

**Proof of Concept:**(Proof of Code)

The below test case shows how anyone can read the password directly from the blockchain.

1. Create a locally running chain
```bash
make anvil
```

2. Deploy the contract to the chain
```bash
make deploy
```

3. Run the storage tool

We use `1` becasue that's the storage slot of `s_password` in the contract.

```bash
cast storage <ADDRESS_HERE> 1 --rpc-url http://127.0.0.1:8545
```

You'll get an output that looks like this:
`0x6d7950617373776f726400000000000000000000000000000000000000000014`

You can then parse that hex to a string value:
```bash
cast parse-bytes32-string 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

And get an output of:
```bash
myPassword
```


**Recommended Mitigation:** Due to this, the overal architechture of the contract should be rethought. One could encrypt the password off-chain, and then store the encrypted password on-chain. This would require the user to remember another password off-chian to decrypt the password. However, you'd also likely want to remove the view function as you wouldn't want the user to accidentally send a transaction with the password that decrypts your password.




---

## Likelihood & Impact:
- Impact: HIGH
- Likelihood: HIGH
- Severity: HIGH



### [S-#] `PasswordStore::setPassword` has no access controls, meaning a non-owner could change the password
### [H-2] Function has access to everyone, without owner new password can be set.

**Desription:** The `PsswordStore::setPassword` function is set to an external function, which allows to set a new passowrd from the outside of the contract. As a result the owener cann't be able to set the new password instead the outsider will set the new password uisng `PassowrdStore::setPassword` function. But this function should allow only the owner to set a new password.

The `PasswordStore::setPassword` function is set to be an `external` function, however, the natspec of the function and overall purpose of the smart contract is that `this function allows only the owner to set a new password.`

```javascript
    function setPassword(string memory newPassword) external {
 @>       // @audit - There a re no access controls
        s_password = newPassword;
        emit SetNewPassword();
    }
```

**Impact:** Anyone can set/change the password of the contract, severly breaking the contract intended functionality.

**Proof of Concept:** Add the following to the `PasswordStore.t.sol` test file.

<details>
<summary>Code</summary>

```javascript
    function test_anyone_can_set_password(address randomAddress) public {
        vm.assume(randomAddress != owner);
        vm.prank(randomAddress);
        string memory expectedPassword = "Alhamdulillah Again";
        passwordStore.setPassword(expectedPassword);

        vm.prank(owner);
        string memory actualPassword = passwordStore.getPassword();
        assertEq(actualPassword, expectedPassword);
    }
```

</details>

**Recommended Mitigation:** Add an access control conditional to the `PasswordStore::setPassword` function.

```javascript
    if(msg.sender != s_owner){
        revert PasswordStore_NotOwner()
    }
```


---

## Likelihood & Impact:
- Impact: HIGH
- Likelihood: HIGH
- severity: HIGH



### [I-1] `PasswordStore::getPassword` Natspec Indicates a Parameter That Doesn't Exist, Causing the Natspec to Be Incorrect

**Description:**

```javascript
/*
 * @notice This allows only the owner to retrieve the password.
 * @param newPassword The new password to set.
 */
function getPassword() external view returns (string memory)
```

The `PasswordStore::getPassword` function signature is `getPassword()`, while the Natspec incorrectly states it should be `getPassword(string)`.

**Impact:** The Natspec is incorrect.

**Recommended Mitigation:** Remove the incorrect Natspec line.

```diff
- * @param newPassword The new password to set.
```


## Likelihood & Impact:
- Impact: NONE
- Likelihood:LOW 
- severity: Informational/Gas/Non-crits

Informational: Hey, this isn't a bug, but you should know...