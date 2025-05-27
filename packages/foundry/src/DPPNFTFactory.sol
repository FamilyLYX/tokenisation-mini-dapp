// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./DPPNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error InvalidInitialOwner();
error InvalidImplementationIsZero();
error InvalidAdminIsZero();

/// @title DPPNFTFactory
/// @notice Deploys minimal proxy clones of the DPPNFT contract using EIP-1167
contract DPPNFTFactory is Ownable {
    using Clones for address;

    address public immutable implementation;
    address public immutable admin;

    mapping(address => bool) public nftContracts;
    address[] public allDPPs;

    event NFTCreated(address indexed nftAddress, address indexed initialOwner);

    /// @param _implementation The address of the DPPNFT implementation contract
    /// @param _admin The address of the admin (typically the deployer or a trusted system account)
    constructor(address _implementation, address _admin) {
        if (_implementation == address(0)) {
            revert InvalidImplementationIsZero();
        }
        if (_admin == address(0)) {
            revert InvalidAdminIsZero();
        }

        implementation = _implementation;
        admin = _admin;
    }

    /// @notice Deploys a clone of the DPPNFT contract and initializes it
    /// @param name Name of the new NFT collection
    /// @param symbol Symbol of the new NFT collection
    /// @param initialOwner Address of the owner of the new NFT
    function createNFT(
        string memory name,
        string memory symbol,
        address initialOwner
    ) external returns (address) {
        if (initialOwner == address(0)) {
            revert InvalidInitialOwner();
        }

        address clone = implementation.clone();
        DPPNFT dpp = DPPNFT(payable(clone));

        dpp.initialize(name, symbol, initialOwner, admin);

        nftContracts[clone] = true;
        allDPPs.push(clone);

        emit NFTCreated(clone, initialOwner);
        return clone;
    }

    function getDeployedDPPs() external view returns (address[] memory) {
        return allDPPs;
    }
}
