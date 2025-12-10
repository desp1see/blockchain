// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/DepositManager.sol";
import "src/Attacker.sol";

contract DepositManagerTest is Test {
    DepositManager public dm;
    Attacker public attacker;

    function setUp() public {
        dm = new DepositManager();
        attacker = new Attacker(address(dm));
    }

    // Test: DoS attack - many deposits make getTotalDeposits gas-intensive
    function testDoSAttack() public {
        uint256 numDeposits = 10_000; // Enough to significantly increase gas usage
        uint256 depositValue = 1 wei;
        uint256 totalValue = numDeposits * depositValue;

        // Fund attacker and execute attack
        vm.deal(address(attacker), totalValue);
        attacker.attack{value: totalValue}(numDeposits);

        // Verify deposits were made
        assertEq(dm.getContractBalance(), totalValue);
        assertEq(dm.getUserDepositCount(address(attacker)), numDeposits);

        // Measure gas used by getTotalDeposits
        uint256 gasStart = gasleft();
        uint256 total = dm.getTotalDeposits();
        uint256 gasUsed = gasStart - gasleft();

        emit log_named_uint("Gas used for getTotalDeposits after attack", gasUsed);

        // Assert that total is correct
        assertEq(total, totalValue);

        // Assert that gas usage is high (scales linearly with deposits)
        // Each iteration ~250-300 gas, so 10k deposits ~2.5M-3M gas
        assertGt(gasUsed, 2_000_000);

        // Simulate DoS: try calling with very limited gas (should fail)
        (bool success, ) = address(dm).staticcall{gas: 500_000}(
            abi.encodeWithSelector(dm.getTotalDeposits.selector)
        );

        assertFalse(success, "getTotalDeposits should fail with insufficient gas");
    }
}