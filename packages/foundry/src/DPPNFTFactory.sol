// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./DPPNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DPPNFTFactory is Ownable {
    mapping(address => bool) public nftContracts;
    address[] public allNFTs;
    mapping(bytes32 => bool) public usedUIDs;
    event NFTCreated(address indexed nftAddress, address indexed initialOwner);

    function createNFT(
        string memory name,
        string memory symbol,
        address initialOwner,
        string memory plainUidCode,
        string memory publicJsonMetadata,
        bytes memory encryptedPrivateMetadata
    ) external returns (address) {
        require(
            initialOwner != address(0),
            "DPPNFTFactory: initialOwner is the zero address"
        );
        bytes32 uidHash = keccak256(abi.encodePacked(plainUidCode));
        // Deploy new DPPNFT contract
        DPPNFT nft = new DPPNFT(name, symbol, address(this));

        // Initialize the NFT with metadata and mint to the initial owner
        nft.initialize(
            initialOwner,
            plainUidCode,
            publicJsonMetadata,
            encryptedPrivateMetadata
        );

        // Register the new NFT contract
        nftContracts[address(nft)] = true;
        allNFTs.push(address(nft));
        usedUIDs[uidHash] = true;

        emit NFTCreated(address(nft), initialOwner);

        return address(nft);
    }

    function isRegisteredNFT(address nftAddress) external view returns (bool) {
        return nftContracts[nftAddress];
    }

    function getDeployedNFTs() external view returns (address[] memory) {
        return allNFTs;
    }
}
