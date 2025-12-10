// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DepositManager {
    mapping(address => uint256) private _balances;
    address private immutable _owner;
    
    struct Deposit {
        uint256 amount;
        uint256 timestamp;
    }
    
    mapping(address => Deposit[]) private _depositHistory;
    Deposit[] private _allDeposits; // Added for vulnerability: global list of all deposits
    
    modifier onlyOwner() {
        require(msg.sender == _owner, "Only owner can call this function");
        _;
    }
    
    constructor() {
        _owner = msg.sender;
    }
    
    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        
        _balances[msg.sender] += msg.value;
        
        Deposit memory newDeposit = Deposit({
            amount: msg.value,
            timestamp: block.timestamp
        });
        
        _depositHistory[msg.sender].push(newDeposit);
        _allDeposits.push(newDeposit); // Added for vulnerability: pushes every deposit to global array
    }
    
    function withdraw(uint256 amount) external {
        require(amount > 0, "Withdrawal amount must be greater than 0");
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        
        _balances[msg.sender] -= amount;
        
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "ETH transfer failed");
    }
    
    function withdrawOwnerFee(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Amount exceeds contract balance");
        
        (bool success, ) = _owner.call{value: amount}("");
        require(success, "ETH transfer failed");
    }
    
    function getUserBalance(address user) external view returns (uint256) {
        return _balances[user];
    }
    
    function getTotalDeposits() external view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < _allDeposits.length; i++) { // Vulnerable loop: sums over unbounded array
            total += _allDeposits[i].amount;
        }
        return total;
    }
    
    function getUserDepositCount(address user) external view returns (uint256) {
        return _depositHistory[user].length;
    }
    
    function getUserDeposit(address user, uint256 index) external view returns (uint256 amount, uint256 timestamp) {
        require(index < _depositHistory[user].length, "Index out of bounds");
        
        Deposit memory depositInfo = _depositHistory[user][index];
        return (depositInfo.amount, depositInfo.timestamp);
    }
    
    function getOwner() external view returns (address) {
        return _owner;
    }
    
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}