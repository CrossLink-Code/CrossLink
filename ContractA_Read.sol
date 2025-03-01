// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ContractA_Read {
    uint256 public storedValue = 42;

    function getValue() external view returns (uint256) {
        return storedValue;
    }
}
