// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import {_LSP4_METADATA_KEY} from "@lukso/lsp4-contracts/contracts/LSP4Constants.sol";
import {LSP8IdentifiableDigitalAsset} from "@lukso/lsp8-contracts/contracts/LSP8IdentifiableDigitalAsset.sol";

contract DPPNFT is LSP8IdentifiableDigitalAsset {
    bytes32 private constant _DPP_UID_HASH_KEY = keccak256("DPP_UID_Hash");
    bytes32 private constant _DPP_ENCRYPTED_METADATA_KEY =
        keccak256("DPP_Encrypted_Metadata"); // Private

    constructor(
        string memory name,
        string memory symbol,
        address initialOwner
    ) LSP8IdentifiableDigitalAsset(name, symbol, initialOwner, 0, 0) {}

    function mintWithSplitMetadata(
        address to,
        bytes32 tokenId,
        string memory plainUidCode,
        string memory publicJsonMetadata,
        bytes memory encryptedPrivateMetadata
    ) public {
        bytes32 uidHash = keccak256(abi.encodePacked(plainUidCode));

        _mint(to, tokenId, true, "");

        _setDataForTokenId(tokenId, _DPP_UID_HASH_KEY, abi.encode(uidHash));
        _setDataForTokenId(
            tokenId,
            _LSP4_METADATA_KEY,
            bytes(publicJsonMetadata)
        );
        _setDataForTokenId(
            tokenId,
            _DPP_ENCRYPTED_METADATA_KEY,
            encryptedPrivateMetadata
        );
    }

    function transferWithUID(
        address from,
        address to,
        bytes32 tokenId,
        bytes memory data,
        string memory plainUidCode
    ) public {
        bytes32 storedHash = abi.decode(
            getDataForTokenId(tokenId, _DPP_UID_HASH_KEY),
            (bytes32)
        );

        require(
            keccak256(abi.encodePacked(plainUidCode)) == storedHash,
            "Invalid UID code"
        );

        transfer(from, to, tokenId, true, data);
    }
}
