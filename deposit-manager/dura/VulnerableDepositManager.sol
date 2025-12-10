// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableDepositManager {
    mapping(address => uint256) private _balances;
    uint256 private _totalDeposits;
    address private immutable _owner;
    
    struct Deposit {
        uint256 amount;
        uint256 timestamp;
    }
    
    mapping(address => Deposit[]) private _depositHistory;
    
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event OwnerFeeWithdrawn(address indexed owner, uint256 amount);
    
    modifier onlyOwner() {
        require(msg.sender == _owner, "Only owner can call this function");
        _;
    }
    
    constructor() {
        _owner = msg.sender;
    }
    
    // УЯЗВИМАЯ ФУНКЦИЯ: Неограниченный рост массива
    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        
        _balances[msg.sender] += msg.value;
        _totalDeposits += msg.value;
        
        // УЯЗВИМОСТЬ: Нет ограничения на количество депозитов
        // Атакующий может создать огромный массив
        _depositHistory[msg.sender].push(Deposit({
            amount: msg.value,
            timestamp: block.timestamp
        }));
        
        emit Deposited(msg.sender, msg.value);
    }
    
    // НОВАЯ УЯЗВИМАЯ ФУНКЦИЯ: Множественные депозиты за одну транзакцию
    function depositManyTimes(uint256 iterations) external payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        require(iterations > 0, "Iterations must be greater than 0");
        
        uint256 amountPerIteration = msg.value / iterations;
        require(amountPerIteration > 0, "Amount per iteration too small");
        
        // УЯЗВИМОСТЬ: Цикл с push в массив
        for(uint256 i = 0; i < iterations; i++) {
            _balances[msg.sender] += amountPerIteration;
            _totalDeposits += amountPerIteration;
            
            // Каждая итерация увеличивает массив
            _depositHistory[msg.sender].push(Deposit({
                amount: amountPerIteration,
                timestamp: block.timestamp
            }));
        }
        
        // Возвращаем сдачу
        uint256 remainder = msg.value - (amountPerIteration * iterations);
        if (remainder > 0) {
            payable(msg.sender).transfer(remainder);
        }
        
        emit Deposited(msg.sender, msg.value - remainder);
    }
    
    function withdraw(uint256 amount) external {
        require(amount > 0, "Withdrawal amount must be greater than 0");
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        
        _balances[msg.sender] -= amount;
        _totalDeposits -= amount;
        
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "ETH transfer failed");
        
        emit Withdrawn(msg.sender, amount);
    }
    
    function withdrawOwnerFee(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient contract balance");
        
        (bool success, ) = _owner.call{value: amount}("");
        require(success, "ETH transfer failed");
        
        emit OwnerFeeWithdrawn(_owner, amount);
    }
    
    // УЯЗВИМАЯ ФУНКЦИЯ ЧТЕНИЯ: может исчерпать газ при большом массиве
    function getUserDepositHistory(address user) external view returns (Deposit[] memory) {
        return _depositHistory[user];
    }
    
    function getUserBalance(address user) external view returns (uint256) {
        return _balances[user];
    }
    
    function getTotalDeposits() external view returns (uint256) {
        return _totalDeposits;
    }
    
    function getUserDepositCount(address user) external view returns (uint256) {
        return _depositHistory[user].length;
    }
    
    function getUserDeposit(address user, uint256 index) external view returns (uint256 amount, uint256 timestamp) {
        require(index < _depositHistory[user].length, "Deposit index out of bounds");
        
        Deposit storage
        depositInfo = _depositHistory[user][index];
        return (depositInfo.amount, depositInfo.timestamp);
    }
    
    function getOwner() external view returns (address) {
        return _owner;
    }
    
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}