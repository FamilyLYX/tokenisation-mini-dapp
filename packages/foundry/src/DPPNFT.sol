// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {_LSP4_METADATA_KEY} from "@lukso/lsp4-contracts/contracts/LSP4Constants.sol";
import {LSP8MintableInitAbstract} from "@lukso/lsp8-contracts/contracts/presets/LSP8MintableInitAbstract.sol";
import {LSP8IdentifiableDigitalAssetInitAbstract} from "@lukso/lsp8-contracts/contracts/LSP8IdentifiableDigitalAssetInitAbstract.sol";
import {ILSP8IdentifiableDigitalAsset} from "@lukso/lsp8-contracts/contracts/ILSP8IdentifiableDigitalAsset.sol";

/// @notice Thrown when a caller is not authorized to perform the action
error Unauthorized();

/// @notice Thrown when the caller is not the owner of the token
error NotTokenOwner();

/// @notice Thrown when the UID hash verification fails
error InvalidUID();

/// @notice Thrown when transfers are attempted through standard means
error TransferNotAllowed();

/// @notice Thrown when attempting to use the zero address
error AddressZeroNotAllowed();

/**
 * @title DPPNFT - Digital Product Passport Non-Fungible Token
 * @notice A LUKSO LSP8-compatible NFT that stores both public and encrypted metadata.
 * @dev UID verification required for token transfer, and direct transfer is disabled.
 */
contract DPPNFT is Initializable, LSP8MintableInitAbstract {
    /// @dev Internal data key used for storing the UID hash
    bytes32 private constant DPP_UID_HASH_KEY = keccak256("DPP_UID_Hash");
    bytes32 private constant DPP_METADATA_KEY = keccak256("DPP_METADATA");

    /// @notice The next token index to be minted
    uint256 public nextTokenIndex;

    /**
     * @notice Initialize the contract
     * @dev Must be called once after deployment
     * @param name_ Token name
     * @param symbol_ Token symbol
     * @param newOwner Owner of the contract
     */
    function initialize(
        string memory name_,
        string memory symbol_,
        address newOwner
    ) external initializer {
        __Ownable_init();
        _initialize(name_, symbol_, newOwner, 0, 0);
    }

    /**
     * @notice Mint a new Digital Product Passport NFT
     * @dev Only the contract owner can mint
     * @param to The address that will receive the newly minted NFT
     * @param publicJsonMetadata The public metadata for the asset, encoded as a JSON string
     * @param uidHash The precomputed UID hash (e.g., keccak256(abi.encodePacked(salt, plainUidCode)))
     */
    function mintDPP(
        address to,
        string memory publicJsonMetadata,
        bytes32 uidHash
    ) external onlyOwner {
        bytes32 tokenId = bytes32(nextTokenIndex++);

        _mint(to, tokenId, true, "0x"); // no additional data

        _setDataForTokenId(
            tokenId,
            DPP_METADATA_KEY,
            bytes(publicJsonMetadata)
        );
        _setDataForTokenId(tokenId, DPP_UID_HASH_KEY, abi.encode(uidHash));
    }

    /**
     * @notice Override standard transfer function to disable normal transfers
     */
    function transfer(
        address,
        address,
        bytes32,
        bool,
        bytes memory
    )
        public
        virtual
        override(
            LSP8IdentifiableDigitalAssetInitAbstract,
            ILSP8IdentifiableDigitalAsset
        )
    {
        revert TransferNotAllowed();
    }

    /**
     * @notice Transfer a token to another address with UID validation and rotation
     * @dev Verifies UID hash before allowing transfer. Replaces old UID hash with a new one.
     * @param tokenId The token ID to transfer
     * @param to Recipient of the token
     * @param data Optional transfer data
     * @param salt Salt used when hashing the original UID
     * @param plainUidCode The original UID (in plaintext)
     * @param newUidHash New UID hash to rotate into after successful validation
     */
    function transferWithUIDRotation(
        bytes32 tokenId,
        address to,
        bytes memory data,
        string calldata salt,
        string calldata plainUidCode,
        bytes32 newUidHash
    ) external {
        if (msg.sender != tokenOwnerOf(tokenId)) {
            revert NotTokenOwner();
        }

        bytes32 storedHash = abi.decode(
            _getDataForTokenId(tokenId, DPP_UID_HASH_KEY),
            (bytes32)
        );

        if (keccak256(abi.encodePacked(salt, plainUidCode)) != storedHash) {
            revert InvalidUID();
        }

        _setDataForTokenId(
            tokenId,
            DPP_UID_HASH_KEY,
            abi.encodePacked(newUidHash)
        );

        _transfer(msg.sender, to, tokenId, true, data);
    }
}
