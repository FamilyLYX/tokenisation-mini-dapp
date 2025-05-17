// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {LSP8IdentifiableDigitalAssetInitAbstract} from "@lukso/lsp8-contracts/contracts/LSP8IdentifiableDigitalAssetInitAbstract.sol";
import {_LSP4_METADATA_KEY} from "@lukso/lsp4-contracts/contracts/LSP4Constants.sol";

contract DPPNFT is LSP8IdentifiableDigitalAssetInitAbstract {
    bytes32 private constant _DPP_UID_HASH_KEY = keccak256("DPP_UID_Hash");
    bytes32 private constant _DPP_ENCRYPTED_METADATA_KEY =
        keccak256("DPP_Encrypted_Metadata");

    address public factory;
    bool private _initialized;
    uint256 public nextTokenId;

    mapping(bytes32 => bytes32) private _uidHashes;
    mapping(bytes32 => bytes) private _encryptedMetadata;

    modifier onlyFactory() {
        require(msg.sender == factory, "DPPNFT: caller is not the factory");
        _;
    }

    modifier notInitialized() {
        require(!_initialized, "DPPNFT: already initialized");
        _;
    }

    function initialize(
        string memory name_,
        string memory symbol_,
        address newOwner_,
        address factoryAddress
    ) external notInitialized {
        require(
            factoryAddress != address(0),
            "DPPNFT: factory address required"
        );

        _initialized = true;
        factory = factoryAddress;

        _initialize(
            name_,
            symbol_,
            newOwner_,
            0, // NFT type
            0 // tokenId format: bytes32
        );
    }

    function mintDPP(
        address to,
        string memory plainUidCode,
        string memory publicJsonMetadata,
        bytes memory encryptedPrivateMetadata
    ) external onlyFactory {
        bytes32 tokenId = bytes32(nextTokenId++);

        bytes32 uidHash = keccak256(abi.encodePacked(plainUidCode));

        _mint(to, tokenId, true, "");

        _setData(_LSP4_METADATA_KEY, bytes(publicJsonMetadata));
        _setData(
            keccak256(abi.encodePacked(_DPP_UID_HASH_KEY, tokenId)),
            abi.encode(uidHash)
        );
        _setData(
            keccak256(abi.encodePacked(_DPP_ENCRYPTED_METADATA_KEY, tokenId)),
            encryptedPrivateMetadata
        );
    }

    function transferOwnershipWithUID(
        bytes32 tokenId,
        address to,
        string memory plainUidCode
    ) external {
        require(msg.sender == tokenOwnerOf(tokenId), "DPPNFT: Not token owner");

        bytes32 storedHash = abi.decode(
            _getData(keccak256(abi.encodePacked(_DPP_UID_HASH_KEY, tokenId))),
            (bytes32)
        );

        require(
            keccak256(abi.encodePacked(plainUidCode)) == storedHash,
            "DPPNFT: Invalid UID code"
        );

        _transfer(msg.sender, to, tokenId, true, "");
    }

    function getUIDHash(bytes32 tokenId) external view returns (bytes32) {
        return
            abi.decode(
                _getData(
                    keccak256(abi.encodePacked(_DPP_UID_HASH_KEY, tokenId))
                ),
                (bytes32)
            );
    }

    function getPublicMetadata(
        bytes32 tokenId
    ) external view returns (string memory) {
        return
            string(
                _getData(
                    keccak256(abi.encodePacked(_LSP4_METADATA_KEY, tokenId))
                )
            );
    }

    function getEncryptedMetadata(
        bytes32 tokenId
    ) external view returns (bytes memory) {
        require(msg.sender == tokenOwnerOf(tokenId), "DPPNFT: Not NFT owner");
        return
            _getData(
                keccak256(
                    abi.encodePacked(_DPP_ENCRYPTED_METADATA_KEY, tokenId)
                )
            );
    }
}
