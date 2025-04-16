// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/DPPNFT.sol"; // adjust path as needed

contract DPPNFTTest is Test {
    DPPNFT public dppNFT;
    address public owner = address(0xABCD);
    address public recipient = address(0x1234);
    bytes32 public tokenId = keccak256("token-001");

    string public plainUid = "unique-product-id";
    bytes32 public uidHash = keccak256(abi.encodePacked(plainUid));
    string public publicMetadata = '{"name":"DPP Watch","type":"physical"}';
    bytes public encryptedMetadata = abi.encode("encrypted-secret");

    function setUp() public {
        dppNFT = new DPPNFT("DPP", "DPPNFT", owner);
    }

    function testMintWithSplitMetadata() public {
        vm.prank(owner);
        dppNFT.mintWithSplitMetadata(
            recipient,
            tokenId,
            plainUid,
            publicMetadata,
            encryptedMetadata
        );

        // Validate UID hash
        bytes32 storedHash = abi.decode(
            dppNFT.getDataForTokenId(tokenId, keccak256("DPP_UID_Hash")),
            (bytes32)
        );
        assertEq(storedHash, uidHash);

        // Validate public metadata
        bytes memory storedMetadata = dppNFT.getDataForTokenId(
            tokenId,
            _LSP4_METADATA_KEY
        );
        assertEq(string(storedMetadata), publicMetadata);

        // Validate encrypted metadata
        bytes memory storedEncrypted = dppNFT.getDataForTokenId(
            tokenId,
            keccak256("DPP_Encrypted_Metadata")
        );
        assertEq(storedEncrypted, encryptedMetadata);

        // Ownership check
        assertEq(dppNFT.ownerOf(tokenId), recipient);
    }

    function testTransferWithCorrectUID() public {
        vm.prank(owner);
        dppNFT.mintWithSplitMetadata(
            owner,
            tokenId,
            plainUid,
            publicMetadata,
            encryptedMetadata
        );

        vm.prank(owner);
        dppNFT.transferWithUID(owner, recipient, tokenId, "", plainUid);

        assertEq(dppNFT.ownerOf(tokenId), recipient);
    }

    function testTransferWithIncorrectUIDShouldRevert() public {
        vm.prank(owner);
        dppNFT.mintWithSplitMetadata(
            owner,
            tokenId,
            plainUid,
            publicMetadata,
            encryptedMetadata
        );

        vm.prank(owner);
        vm.expectRevert("Invalid UID code");
        dppNFT.transferWithUID(owner, recipient, tokenId, "", "wrong-code");
    }
}
