// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./DPPNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DPPNFTFactory is Ownable {
    using Clones for address;

    address public immutable implementation;
    mapping(address => bool) public nftContracts;
    address[] public allNFTs;
    mapping(bytes32 => bool) public usedUIDs;

    event NFTCreated(address indexed nftAddress, address indexed initialOwner);

    constructor(address _implementation) {
        implementation = _implementation;
    }

    function createNFT(
        address initialOwner,
        string memory plainUidCode,
        string memory publicJsonMetadata,
        bytes memory encryptedPrivateMetadata
    ) external returns (address) {
        require(initialOwner != address(0), "Invalid owner");

        bytes32 uidHash = keccak256(abi.encodePacked(plainUidCode));
        require(!usedUIDs[uidHash], "UID already used");

        address clone = implementation.clone();

        DPPNFT(clone).initialize(
            initialOwner,
            plainUidCode,
            publicJsonMetadata,
            encryptedPrivateMetadata
        );

        nftContracts[clone] = true;
        allNFTs.push(clone);
        usedUIDs[uidHash] = true;

        emit NFTCreated(clone, initialOwner);
        return clone;
    }

    function isRegisteredNFT(address nftAddress) external view returns (bool) {
        return nftContracts[nftAddress];
    }

    function getDeployedNFTs() external view returns (address[] memory) {
        return allNFTs;
    }
}
