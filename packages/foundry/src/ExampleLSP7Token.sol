// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract DPPNFT is Initializable, LSP8MintableInit, LSP8BurnableInit {
    bytes32 internal constant UID_HASH_KEY = keccak256("DPP_UID_Hash");

    function initialize(
        string memory name_,
        string memory symbol_,
        address newOwner_
    ) public initializer {
        LSP8MintableInit_init(name_, symbol_, newOwner_, true);
    }

    /// @notice Mint DPP NFT with associated metadata and UID hash
    function mintDPP(
        address to,
        bytes32 tokenId,
        string memory plainUidCode,
        bytes memory lsp4Metadata
    ) public onlyOwner {
        _mint(to, tokenId, true, "");

        // Store LSP4 metadata (public)
        _setData(_generateDataKey(tokenId, _LSP4_METADATA_KEY), lsp4Metadata);

        // Store UID hash (private)
        bytes32 uidHash = keccak256(abi.encodePacked(plainUidCode));
        _setData(
            _generateDataKey(tokenId, UID_HASH_KEY),
            abi.encodePacked(uidHash)
        );
    }

    /// @notice Overridden transfer requiring UID verification
    function transferWithUidCheck(
        address from,
        address to,
        bytes32 tokenId,
        string memory plainUidCode,
        bool force,
        bytes memory data
    ) public {
        bytes32 expectedHash = keccak256(abi.encodePacked(plainUidCode));
        bytes32 storedHash = bytes32(
            getData(_generateDataKey(tokenId, UID_HASH_KEY))
        );
        require(expectedHash == storedHash, "Invalid UID code");

        // Perform standard LSP8 transfer
        transfer(from, to, tokenId, force, data);
    }

    function _generateDataKey(
        bytes32 tokenId,
        bytes32 dataKeyPrefix
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(dataKeyPrefix, tokenId));
    }
}
