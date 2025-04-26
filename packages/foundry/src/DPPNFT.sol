// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {_LSP4_METADATA_KEY} from "@lukso/lsp4-contracts/contracts/LSP4Constants.sol";
import {LSP8IdentifiableDigitalAsset} from "@lukso/lsp8-contracts/contracts/LSP8IdentifiableDigitalAsset.sol";

contract DPPNFT is LSP8IdentifiableDigitalAsset {
    bytes32 private constant _DPP_UID_HASH_KEY = keccak256("DPP_UID_Hash");
    bytes32 private constant _DPP_ENCRYPTED_METADATA_KEY =
        keccak256("DPP_Encrypted_Metadata"); // Private

    address public factory;
    bool private _initialized;
    bytes32 private constant TOKEN_ID = bytes32(uint256(1)); // Fixed tokenId for the single asset

    modifier onlyFactory() {
        require(msg.sender == factory, "DPPNFT: caller is not the factory");
        _;
    }

    modifier notInitialized() {
        require(!_initialized, "DPPNFT: already initialized");
        _;
    }

    constructor(
        string memory name,
        string memory symbol,
        address factoryAddress
    ) LSP8IdentifiableDigitalAsset(name, symbol, factoryAddress, 0, 0) {
        factory = factoryAddress;
    }

    function initialize(
        address to,
        string memory plainUidCode,
        string memory publicJsonMetadata,
        bytes memory encryptedPrivateMetadata
    ) external onlyFactory notInitialized {
        _initialized = true;

        bytes32 uidHash = keccak256(abi.encodePacked(plainUidCode));
        _mint(to, TOKEN_ID, true, "");

        // Store metadata directly using ERC725Y storage
        _setData(_DPP_UID_HASH_KEY, abi.encode(uidHash));
        _setData(_LSP4_METADATA_KEY, bytes(publicJsonMetadata));
        _setData(_DPP_ENCRYPTED_METADATA_KEY, encryptedPrivateMetadata);
    }

    function transferOwnershipWithUID(
        address to,
        string memory plainUidCode
    ) external onlyOwner {
        bytes32 storedHash = abi.decode(_getData(_DPP_UID_HASH_KEY), (bytes32));
        require(
            keccak256(abi.encodePacked(plainUidCode)) == storedHash,
            "DPPNFT: Invalid UID code"
        );

        _transfer(msg.sender, to, TOKEN_ID, true, "");
    }

    // Helper functions
    function getUIDHash() external view returns (bytes32) {
        return abi.decode(_getData(_DPP_UID_HASH_KEY), (bytes32));
    }

    function getPublicMetadata() external view returns (bytes memory) {
        return _getData(_LSP4_METADATA_KEY);
    }

    function getEncryptedMetadata() external view returns (bytes memory) {
        require(msg.sender == tokenOwnerOf(TOKEN_ID), "DPPNFT: Not NFT owner");
        return _getData(_DPP_ENCRYPTED_METADATA_KEY);
    }

    function transfer(
        address from,
        address to,
        bytes32 tokenId,
        bool force,
        bytes memory data
    ) public override {
        super.transfer(from, to, tokenId, force, data);
    }

    // Returns the current owner of the NFT
    function owner() public view override returns (address) {
        try this.tokenOwnerOf(TOKEN_ID) returns (address tokenOwner) {
            return tokenOwner;
        } catch {
            return address(0);
        }
    }
}
