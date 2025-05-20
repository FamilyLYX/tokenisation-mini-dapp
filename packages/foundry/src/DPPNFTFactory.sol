// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./DPPNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error InvalidInitialOwner();

/// @title DPPNFTFactory
/// @notice Deploys minimal proxy clones of the DPPNFT contract using EIP-1167
contract DPPNFTFactory is Ownable {
    using Clones for address;

    // ------------------------------------------------------------------------
    // State Variables
    // ------------------------------------------------------------------------
    address public immutable implementation;
    mapping(address => bool) public nftContracts;
    address[] public allDPPs;

    // ------------------------------------------------------------------------
    // Events
    // ------------------------------------------------------------------------
    event NFTCreated(address indexed nftAddress, address indexed initialOwner);

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    /// @param _implementation The address of the DPPNFT implementation contract
    constructor(address _implementation) {
        implementation = _implementation;
    }

    // ------------------------------------------------------------------------
    // NFT Deployment
    // ------------------------------------------------------------------------
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
        dpp.initialize(name, symbol, initialOwner, address(this));

        nftContracts[clone] = true;
        allDPPs.push(clone);

        emit NFTCreated(clone, initialOwner);
        return clone;
    }

    // ------------------------------------------------------------------------
    // View Functions
    // ------------------------------------------------------------------------

    /// @notice Checks if a given address is a valid deployed DPP NFT
    /// @param nftAddress The address to check
    function isRegisteredNFT(address nftAddress) external view returns (bool) {
        return nftContracts[nftAddress];
    }

    /// @notice Returns all deployed DPP NFT addresses
    function getDeployedDPPs() external view returns (address[] memory) {
        return allDPPs;
    }
}
