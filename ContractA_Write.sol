// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ContractA_Write {
    uint256 public storedValue = 0;

    function setValue(uint256 _newValue) external returns (bool) {
        storedValue = _newValue;
        return true;
    }
}
