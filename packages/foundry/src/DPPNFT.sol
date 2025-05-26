// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {LSP8IdentifiableDigitalAssetInitAbstract} from "@lukso/lsp8-contracts/contracts/LSP8IdentifiableDigitalAssetInitAbstract.sol";
import {_LSP4_METADATA_KEY} from "@lukso/lsp4-contracts/contracts/LSP4Constants.sol";

error Unauthorized();
error NotTokenOwner();
error InvalidUID();
error TransferNotAllowed();
error AddressZeroNotAllowed();

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
    bytes32 private constant _DPP_UID_SALT_KEY = keccak256("DPP_UID_Salt");

    address public admin;
    uint256 public nextTokenIndex;

    modifier onlyAdmin() {
        if (msg.sender != admin) revert Unauthorized();
        _;
    }

    function initialize(
        string memory name_,
        string memory symbol_,
        address newOwner_,
        address adminAddress
    ) external initializer {
        if (adminAddress == address(0)) revert AddressZeroNotAllowed();

        __Ownable_init();
        _initialize(name_, symbol_, newOwner_, 0, 0);

        admin = adminAddress;
    }

    function mintDPP(
        address to,
        string memory plainUidCode,
        string memory publicJsonMetadata
    ) external onlyOwner {
        bytes32 tokenId = bytes32(nextTokenIndex++);

        bytes32 salt = keccak256(
            abi.encodePacked(
                msg.sender,
                tokenId,
                block.timestamp,
                blockhash(block.number - 1)
            )
        );

        bytes32 uidHash = keccak256(abi.encodePacked(salt, plainUidCode));

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
            keccak256(abi.encodePacked(_DPP_UID_SALT_KEY, tokenId)),
            abi.encode(salt)
        );
    }

    /// @dev Block public transfer unless called by admin
    function transfer(
        address from,
        address to,
        bytes32 tokenId,
        bool allowNonTokenOwner,
        bytes memory data
    ) public virtual override {
        if (msg.sender != admin) revert TransferNotAllowed();
        _transfer(from, to, tokenId, allowNonTokenOwner, data);
    }

    /// @dev Token owner can transfer using UID
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

        bytes32 salt = abi.decode(
            _getData(keccak256(abi.encodePacked(_DPP_UID_SALT_KEY, tokenId))),
            (bytes32)
        );

        if (keccak256(abi.encodePacked(salt, plainUidCode)) != storedHash)
            revert InvalidUID();

        _transfer(msg.sender, to, tokenId, true, "");
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
}
