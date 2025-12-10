// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RevertTrap {
    fallback() external payable {
        revert("No thx");
    }

    receive() external payable {
        revert("No thx");
    }
}