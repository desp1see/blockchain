// test/RevertTrapTest.t.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "kor/VulnerablePayout.sol";
import "kor/RevertTrap.sol";

contract VulnerablePayoutTest is Test {
    VulnerablePayout public vault;
    RevertTrap public trap;
    address public sasha = address(0xA1);
    address public tom = address(0xB2);

    function setUp() public {
        vault = new VulnerablePayout();
        trap = new RevertTrap();

        vm.deal(sasha, 10 ether);
        vm.deal(tom, 10 ether);
        vm.deal(address(trap), 10 ether); 
    }

    function testDoSPayout() public {
        vm.prank(sasha);
        vault.deposit{value: 1 ether}();

        vm.prank(tom);
        vault.deposit{value: 1 ether}();

        vm.prank(address(trap));
        vault.deposit{value: 1 ether}();

        vm.expectRevert("Transfer failed");
        vault.payoutAll();

        assertEq(sasha.balance, 9 ether);
        assertEq(vault.balances(sasha), 1 ether);
    }
}