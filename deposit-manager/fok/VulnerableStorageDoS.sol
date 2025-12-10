// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VulnerableStorageDoS {
    uint256[] public history;

    function spamStorage(uint256 count) external {
        for (uint256 i = 0; i < count; i++) {
            history.push(i);
        }
    }

    function clearHistory() external {
        // Уязвимость: цикл по storage → гарантированный DoS
        for (uint256 i = 0; i < history.length; i++) {
            delete history[i];
        }
        delete history;
    }
}
