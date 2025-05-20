// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {LSP8IdentifiableDigitalAssetInitAbstract} from "@lukso/lsp8-contracts/contracts/LSP8IdentifiableDigitalAssetInitAbstract.sol";
import {_LSP4_METADATA_KEY} from "@lukso/lsp4-contracts/contracts/LSP4Constants.sol";

error InvalidFactory();
error Unauthorized();
error NotTokenOwner();
error InvalidUID();

/**
 * @title DPPNFT - Digital Product Passport Non-Fungible Token
 * @dev A LUKSO LSP8-compatible NFT that stores both public and encrypted metadata.
 */
contract DPPNFT is
    Initializable,
    OwnableUpgradeable,
    LSP8IdentifiableDigitalAssetInitAbstract
{
    bytes32 private constant _DPP_UID_HASH_KEY = keccak256("DPP_UID_Hash");
    bytes32 private constant _DPP_ENCRYPTED_METADATA_KEY =
        keccak256("DPP_Encrypted_Metadata");

    address public factory;
    uint256 public nextTokenIndex;

    modifier onlyFactory() {
        if (msg.sender != factory) revert InvalidFactory();
        _;
    }

    /// @notice Initializes the contract (LSP8, Ownable, Factory)
    function initialize(
        string memory name_,
        string memory symbol_,
        address newOwner_,
        address factoryAddress
    ) external initializer {
        if (factoryAddress == address(0)) revert InvalidFactory();

        __Ownable_init();
        _initialize(name_, symbol_, newOwner_, 0, 0);
        factory = factoryAddress;
    }

    /// @notice Mints a new DPP with associated metadata
    function mintDPP(
        address to,
        string memory plainUidCode,
        string memory publicJsonMetadata,
        bytes memory encryptedPrivateMetadata
    ) external onlyFactory {
        bytes32 tokenId = keccak256(
            abi.encodePacked(nextTokenIndex++, block.timestamp, to)
        );
        bytes32 uidHash = keccak256(abi.encodePacked(plainUidCode));

        _mint(to, tokenId, true, "");

        _setData(
            keccak256(abi.encodePacked(_LSP4_METADATA_KEY, tokenId)),
            bytes(publicJsonMetadata)
        );
        _setData(
            keccak256(abi.encodePacked(_DPP_UID_HASH_KEY, tokenId)),
            abi.encode(uidHash)
        );
        _setData(
            keccak256(abi.encodePacked(_DPP_ENCRYPTED_METADATA_KEY, tokenId)),
            encryptedPrivateMetadata
        );
    }

    /// @notice Transfers token to a new owner using a verified UID
    function transferOwnershipWithUID(
        bytes32 tokenId,
        address to,
        string memory plainUidCode
    ) external {
        if (msg.sender != tokenOwnerOf(tokenId)) revert NotTokenOwner();

        bytes32 storedHash = abi.decode(
            _getData(keccak256(abi.encodePacked(_DPP_UID_HASH_KEY, tokenId))),
            (bytes32)
        );

        if (keccak256(abi.encodePacked(plainUidCode)) != storedHash)
            revert InvalidUID();

        _transfer(msg.sender, to, tokenId, true, "");
    }

    /// @notice Returns the UID hash associated with a token
    function getUIDHash(bytes32 tokenId) external view returns (bytes32) {
        return
            abi.decode(
                _getData(
                    keccak256(abi.encodePacked(_DPP_UID_HASH_KEY, tokenId))
                ),
                (bytes32)
            );
    }

    /// @notice Returns public metadata as JSON string
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

    /// @notice Returns encrypted metadata (only for owner or operator)
    function getEncryptedMetadata(
        bytes32 tokenId
    ) external view returns (bytes memory) {
        if (
            msg.sender != tokenOwnerOf(tokenId) &&
            !isOperatorFor(msg.sender, tokenId)
        ) revert Unauthorized();

        return
            _getData(
                keccak256(
                    abi.encodePacked(_DPP_ENCRYPTED_METADATA_KEY, tokenId)
                )
            );
    }

    /// @notice Updates the factory address
    function setFactory(address newFactory) external onlyOwner {
        if (newFactory == address(0)) revert InvalidFactory();
        factory = newFactory;
    }
}
