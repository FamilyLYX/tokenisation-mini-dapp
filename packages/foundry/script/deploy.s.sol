// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Script, console} from "forge-std/Script.sol";
import {DPPNFTFactory} from "../src/DPPNFTFactory.sol";

contract DeployScript is Script {
    function run() external {
        // Load deployer's private key from environment variable
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        DPPNFTFactory factory = new DPPNFTFactory();

        console.log("DPPNFTFactory deployed at:", address(factory));
        console.log("Owner set to:", deployer);

        vm.stopBroadcast();
    }
}
