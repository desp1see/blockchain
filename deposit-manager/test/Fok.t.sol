// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "fok/VulnerableStorageDoS.sol";
import "fok/StorageAttacker.sol";

contract StorageDoSTest is Test {
    VulnerableStorageDoS public vuln;
    DoSAttacker public attacker;

    function setUp() public {
        vuln = new VulnerableStorageDoS();
        attacker = new DoSAttacker(address(vuln));
    }

    function test_DoS_Attack_Blocks_ClearHistory() public {
        // Подготовка — создаём огромный массив
        // loops * batch = итоговое число элементов
        uint256 loops = 50;
        uint256 batch = 2000;

        // ожидаем что clearHistory упадёт внутри performAttack
        vm.expectRevert();

        attacker.performAttack(loops, batch);
    }
}
