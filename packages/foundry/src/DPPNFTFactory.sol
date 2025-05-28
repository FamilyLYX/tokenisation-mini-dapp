// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./DPPNFT.sol";

error InvalidInitialOwner();
error InvalidImplementationIsZero();

/// @title DPPNFTFactory
/// @notice Deploys minimal proxy clones of the DPPNFT contract using EIP-1167 proxy standard
contract DPPNFTFactory is Ownable {
    using Clones for address;

    /// @notice The address of the DPPNFT implementation contract used for cloning
    address public immutable implementation;

    /// @notice Mapping to track deployed DPPNFT clone contracts
    mapping(address => bool) public nftContracts;

    /// @notice List of all deployed DPPNFT clone addresses
    address[] public allDPPs;

    /// @param _implementation The address of the DPPNFT implementation contract to clone
    constructor(address _implementation) {
        if (_implementation == address(0)) {
            revert InvalidImplementationIsZero();
        }
        implementation = _implementation;
    }

    /// @notice Deploys a new clone of the DPPNFT contract and initializes it
    /// @param name The name for the new NFT collection
    /// @param symbol The symbol for the new NFT collection
    /// @param initialOwner The initial owner address of the newly deployed NFT contract
    /// @return clone The address of the deployed NFT clone contract
    function createNFT(
        string memory name,
        string memory symbol,
        address initialOwner
    ) external returns (address clone) {
        if (initialOwner == address(0)) {
            revert InvalidInitialOwner();
        }

        clone = implementation.clone();
        DPPNFT(payable(clone)).initialize(name, symbol, initialOwner);

        nftContracts[clone] = true;
        allDPPs.push(clone);

        emit NFTCreated(clone, initialOwner);
    }

    /// @notice Returns an array of all deployed DPPNFT clone addresses
    /// @return An array containing addresses of all deployed NFT clones
    function getDeployedDPPs() external view returns (address[] memory) {
        return allDPPs;
    }

    /// @notice Emitted when a new DPPNFT clone is created
    /// @param nftAddress The address of the deployed NFT clone contract
    /// @param initialOwner The initial owner of the deployed NFT clone
    event NFTCreated(address indexed nftAddress, address indexed initialOwner);
}
