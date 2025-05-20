// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/DPPNFT.sol";

contract DPPNFTTest is Test {
    DPPNFT public dpp;
    address public factory = address(0xFACA);
    address public user = address(0xBEEF);
    address public newOwner = address(0xCAFE);

    string public name = "Demo Product Pass";
    string public symbol = "DPP";

    string public uid = "UNIQUE-UID-123";
    string public publicMetadata = '{"name":"Product","description":"Info"}';
    bytes public encryptedMetadata = abi.encode("secret-metadata");

    bytes32 public tokenId;

    function setUp() public {
        dpp = new DPPNFT();
        vm.prank(factory);
        dpp.initialize(name, symbol, factory, factory);
    }

    function testMintDPP() public {
        vm.prank(factory);
        dpp.mintDPP(user, uid, publicMetadata, encryptedMetadata);

        // tokenId is generated inside mintDPP: get last tokenId (nextTokenIndex-1)
        uint256 lastIndex = dpp.nextTokenIndex() - 1;
        // Recompute tokenId the same way mintDPP does
        tokenId = keccak256(abi.encodePacked(lastIndex, block.timestamp, user));

        // Can't directly get tokenId from contract, so we simulate the same logic:
        // To avoid block.timestamp issues, let's just fetch tokenOwnerOf for all tokens.

        // Instead, check ownership by scanning tokens or use event logs (better).
        // Here, we just test ownership by reading tokenOwnerOf for computed tokenId:
        address owner = dpp.tokenOwnerOf(tokenId);
        assertEq(owner, user);

        // Verify UID hash stored
        bytes32 expectedUidHash = keccak256(abi.encodePacked(uid));
        bytes32 storedUidHash = dpp.getUIDHash(tokenId);
        assertEq(storedUidHash, expectedUidHash);

        // Verify public metadata
        string memory storedMetadata = dpp.getPublicMetadata(tokenId);
        assertEq(storedMetadata, publicMetadata);
    }

    function testOnlyFactoryCanMint() public {
        vm.expectRevert(InvalidFactory.selector); 
        dpp.mintDPP(user, uid, publicMetadata, encryptedMetadata);
    }

    function testEncryptedMetadataOnlyOwnerOrOperatorCanRead() public {
        vm.prank(factory);
        dpp.mintDPP(user, uid, publicMetadata, encryptedMetadata);

        uint256 lastIndex = dpp.nextTokenIndex() - 1;
        tokenId = keccak256(abi.encodePacked(lastIndex, block.timestamp, user));

        // Non-owner tries to read encrypted metadata
        vm.expectRevert(Unauthorized.selector);
        dpp.getEncryptedMetadata(tokenId);

        // Owner reads encrypted metadata
        vm.prank(user);
        bytes memory data = dpp.getEncryptedMetadata(tokenId);
        assertEq(data, encryptedMetadata);
    }

    function testTransferOwnershipWithUID() public {
        vm.prank(factory);
        dpp.mintDPP(user, uid, publicMetadata, encryptedMetadata);

        uint256 lastIndex = dpp.nextTokenIndex() - 1;
        tokenId = keccak256(abi.encodePacked(lastIndex, block.timestamp, user));

        // Transfer with correct UID
        vm.prank(user);
        dpp.transferOwnershipWithUID(tokenId, newOwner, uid);

        // Check new token owner
        address owner = dpp.tokenOwnerOf(tokenId);
        assertEq(owner, newOwner);
    }

    function testTransferOwnershipWithInvalidUID() public {
        vm.prank(factory);
        dpp.mintDPP(user, uid, publicMetadata, encryptedMetadata);

        uint256 lastIndex = dpp.nextTokenIndex() - 1;
        tokenId = keccak256(abi.encodePacked(lastIndex, block.timestamp, user));

        vm.prank(user);
        vm.expectRevert(InvalidUID.selector);
        dpp.transferOwnershipWithUID(tokenId, newOwner, "wrong-uid");
    }
}
