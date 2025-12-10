// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleWallet {
    address public owner;

    event Received(address indexed from, uint amount);
    event Sent(address indexed to, uint amount);

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function sendETH(address payable _to, uint _amount) public {
        require(msg.sender == owner, "Only owner");
        require(address(this).balance >= _amount, "Not enough ETH");
        _to.transfer(_amount);
        emit Sent(_to, _amount);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
