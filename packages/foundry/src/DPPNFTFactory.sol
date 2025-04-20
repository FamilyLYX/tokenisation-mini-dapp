// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./DPPNFT.sol";

contract DPPNFTFactory {
    address public owner;
    mapping(address => bool) public nftContracts;

    event NFTCreated(address indexed nftAddress, address indexed initialOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "DPPNFTFactory: caller is not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(
            newOwner != address(0),
            "DPPNFTFactory: new owner is the zero address"
        );
        owner = newOwner;
    }

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

        emit NFTCreated(address(nft), initialOwner);

        return address(nft);
    }

    function isRegisteredNFT(address nftAddress) external view returns (bool) {
        return nftContracts[nftAddress];
    }
}
