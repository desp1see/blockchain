// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerablePayout {
    mapping(address => uint256) public balances;
    address[] public users;  // ← список всех, кто внёс депозит
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function deposit() external payable {
        if (balances[msg.sender] == 0) {
            users.push(msg.sender);  // ← добавляем в список
        }
        balances[msg.sender] += msg.value;
    }

    // УЯЗВИМАЯ ФУНКЦИЯ
    function payoutAll() external {
        for (uint i = 0; i < users.length; i++) {
            address user = users[i];
            uint256 amount = balances[user];
            if (amount > 0) {
                balances[user] = 0;
                (bool success, ) = user.call{value: amount}("");
                require(success, "Transfer failed");  // ← DoS!
            }
        }
    }

    // Для владельца
    function withdrawOwner() external {
        require(msg.sender == owner);
        payable(owner).transfer(address(this).balance);
    }
}