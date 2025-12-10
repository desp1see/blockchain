// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/SimpleWallet.sol";

contract DeploySimpleWallet is Script {
    function run() external {
        vm.startBroadcast();
        new SimpleWallet();
        vm.stopBroadcast();
    }
}
