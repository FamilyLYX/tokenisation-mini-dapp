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

    bytes32 public tokenId = bytes32(uint256(1));
    bytes32 public uidHash;

    function setUp() public {
        vm.prank(factory);
        dpp = new DPPNFT(name, symbol, factory);
        uidHash = keccak256(abi.encodePacked(uid));
    }

    function testInitialize() public {
        vm.prank(factory);
        dpp.initialize(user, uid, publicMetadata, encryptedMetadata);

        // Verify token owner
        assertEq(dpp.owner(), user);

        // Verify UID hash stored
        assertEq(dpp.getUIDHash(), uidHash);

        // Verify public metadata
        assertEq(string(dpp.getPublicMetadata()), publicMetadata);

        // Fail re-initialization
        vm.expectRevert("DPPNFT: already initialized");
        vm.prank(factory);
        dpp.initialize(user, uid, publicMetadata, encryptedMetadata);
    }

    function testOnlyFactoryCanInitialize() public {
        vm.expectRevert("DPPNFT: caller is not the factory");
        dpp.initialize(user, uid, publicMetadata, encryptedMetadata);
    }

    function testEncryptedMetadataOnlyOwnerCanRead() public {
        vm.prank(factory);
        dpp.initialize(user, uid, publicMetadata, encryptedMetadata);

        // Non-owner tries to read encrypted metadata
        vm.expectRevert("DPPNFT: Not NFT owner");
        dpp.getEncryptedMetadata();

        // Let user read it
        vm.prank(user);
        bytes memory data = dpp.getEncryptedMetadata();
        assertEq(data, encryptedMetadata);
    }

    function testTransferOwnershipWithUID() public {
        vm.prank(factory);
        dpp.initialize(user, uid, publicMetadata, encryptedMetadata);

        // Transfer with correct UID
        vm.prank(user);
        dpp.transferOwnershipWithUID(newOwner, uid);

        assertEq(dpp.owner(), newOwner);
    }

    function testTransferOwnershipWithInvalidUID() public {
        vm.prank(factory);
        dpp.initialize(user, uid, publicMetadata, encryptedMetadata);

        // Try invalid UID
        vm.prank(user);
        vm.expectRevert("DPPNFT: Invalid UID code");
        dpp.transferOwnershipWithUID(newOwner, "wrong-uid");
    }
}
