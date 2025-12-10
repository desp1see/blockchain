// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/PixelBattle.sol";

contract DeployPixelBattle is Script {
    function run() external {
        vm.startBroadcast();
        new PixelBattle();
        vm.stopBroadcast();
    }
}
