// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Script, console} from "forge-std/Script.sol";
import {DPPNFT} from "../src/DPPNFT.sol";

contract DeployDPPNFT is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        DPPNFT nft = new DPPNFT("DPP NFT", "DPP", deployer);

        console.log("Deployed DPPNFT at:", address(nft));
        console.log("Owner set to:", deployer);

        vm.stopBroadcast();
    }
}
