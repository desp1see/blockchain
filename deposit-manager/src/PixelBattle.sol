// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PixelBattle {
    uint8 constant WIDTH = 64;
    uint8 constant HEIGHT = 64;
    uint256 public constant PIXEL_PRICE = 0.01 ether;
    uint256 public constant COOLDOWN = 5 minutes;

    // Ключ: (x << 8) | y => цвет (0-255, серый)
    mapping(uint256 => uint8) public canvas;
    mapping(address => uint256) public lastPlaced;

    address public owner;
    uint256 public totalPixelsPlaced;

    event PixelPlaced(address indexed user, uint8 x, uint8 y, uint8 color);

    constructor() {
        owner = msg.sender;
    }

    function placePixel(uint8 x, uint8 y, uint8 color) external payable {
        require(msg.value >= PIXEL_PRICE, "Pay at least 0.01 ETH");
        require(x < WIDTH && y < HEIGHT, "Out of bounds");
        require(block.timestamp >= lastPlaced[msg.sender] + COOLDOWN, "Wait for cooldown");

        uint256 key = (uint256(x) << 8) | y;
        canvas[key] = color;
        lastPlaced[msg.sender] = block.timestamp;
        totalPixelsPlaced++;

        emit PixelPlaced(msg.sender, x, y, color);
    }

    function getPixel(uint8 x, uint8 y) external view returns (uint8) {
        require(x < WIDTH && y < HEIGHT, "Out of bounds");
        uint256 key = (uint256(x) << 8) | y;
        return canvas[key];
    }

    function getCanvas() external view returns (bytes memory) {
        bytes memory data = new bytes(WIDTH * HEIGHT);
        for (uint8 x = 0; x < WIDTH; x++) {
            for (uint8 y = 0; y < HEIGHT; y++) {
                uint256 key = (uint256(x) << 8) | y;
                data[x * HEIGHT + y] = bytes1(canvas[key]);
            }
        }
        return data;
    }

    function withdraw() external {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(owner).transfer(address(this).balance);
    }
}