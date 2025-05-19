// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./DPPNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DPPNFTFactory is Ownable {
    using Clones for address;

    address public immutable implementation;
    mapping(address => bool) public nftContracts;
    address[] public allDPPs;

    event NFTCreated(address indexed nftAddress, address indexed initialOwner);

    constructor(address _implementation) {
        implementation = _implementation;
    }

    function createNFT(
        string memory name,
        string memory symbol,
        address initialOwner
    ) external returns (address) {
        require(initialOwner != address(0), "Invalid owner");

        address clone = implementation.clone();
        DPPNFT dpp = DPPNFT(payable(clone));
        dpp.initialize(name, symbol, initialOwner, address(this));

        nftContracts[clone] = true;
        allDPPs.push(clone);

        emit NFTCreated(clone, initialOwner);
        return clone;
    }

    function isRegisteredNFT(address nftAddress) external view returns (bool) {
        return nftContracts[nftAddress];
    }

    function getDeployedDPPs() external view returns (address[] memory) {
        return allDPPs;
    }
}
