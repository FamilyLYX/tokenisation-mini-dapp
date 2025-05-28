// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Script, console} from "forge-std/Script.sol";
import {DPPNFTFactory} from "../src/DPPNFTFactory.sol";
import {DPPNFT} from "../src/DPPNFT.sol";

contract DeployScript is Script {
    function run() external {
        // Load deployer's private key from environment variable
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy the DPPNFT implementation contract (logic contract)
        DPPNFT implementation = new DPPNFT();
        console.log(
            "DPPNFT implementation deployed at:",
            address(implementation)
        );

        // 2. Deploy the factory contract with the implementation address
        DPPNFTFactory factory = new DPPNFTFactory(
            address(implementation),
            deployer
        );
        console.log("DPPNFTFactory deployed at:", address(factory));
        console.log("Owner set to:", deployer);

        vm.stopBroadcast();
    }
}
