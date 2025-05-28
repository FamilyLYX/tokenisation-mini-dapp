// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/DPPNFT.sol";

contract DPPNFTTest is Test {
    DPPNFT public dpp;

    address public deployer = address(0xDEADBEEF);
    address public admin = address(0xA11CE);
    address public user = address(0xBEEF);
    address public newOwner = address(0xCAFE);

    string public name = "Demo Product Pass";
    string public symbol = "DPP";

    string public uid = "UNIQUE-UID-123";
    string public salt = "RANDOM-SALT";
    string public publicMetadata = '{"name":"Product","description":"Info"}';

    bytes32 public tokenId;

    function setUp() public {
        dpp = new DPPNFT();

        // Simulate the deployer calling initialize to become owner
        vm.prank(deployer);
        dpp.initialize(name, symbol, deployer, admin);
    }

    function testOwnerCanMintDPP() public {
        vm.prank(deployer);
        dpp.mintDPP(user, uid, publicMetadata, salt);

        tokenId = bytes32(0);

        address owner = dpp.tokenOwnerOf(tokenId);
        assertEq(owner, user);

        string memory rawMetadata = dpp.getPublicMetadata(tokenId);
        assertEq(rawMetadata, publicMetadata);
    }

    function testOnlyOwnerCanMint() public {
        vm.expectRevert("Ownable: caller is not the owner");
        dpp.mintDPP(user, uid, publicMetadata, salt);
    }

    function testTransferBlockedForNonAdmin() public {
        vm.prank(deployer);
        dpp.mintDPP(user, uid, publicMetadata, salt);

        tokenId = bytes32(0);

        vm.prank(user);
        vm.expectRevert(TransferNotAllowed.selector);
        dpp.transfer(user, newOwner, tokenId, true, "");
    }

    function testAdminCanTransfer() public {
        vm.prank(deployer);
        dpp.mintDPP(user, uid, publicMetadata, salt);

        tokenId = bytes32(0);

        vm.prank(admin);
        dpp.transfer(user, newOwner, tokenId, true, "");

        address owner = dpp.tokenOwnerOf(tokenId);
        assertEq(owner, newOwner);
    }

    function testTransferWithCorrectUIDAndSalt() public {
        vm.prank(deployer);
        dpp.mintDPP(user, uid, publicMetadata, salt);

        tokenId = bytes32(0);

        vm.prank(user);
        dpp.transferOwnershipWithUID(tokenId, newOwner, uid, salt);

        address owner = dpp.tokenOwnerOf(tokenId);
        assertEq(owner, newOwner);
    }

    function testTransferWithInvalidUIDFails() public {
        vm.prank(deployer);
        dpp.mintDPP(user, uid, publicMetadata, salt);

        tokenId = bytes32(0);

        vm.prank(user);
        vm.expectRevert(InvalidUID.selector);
        dpp.transferOwnershipWithUID(tokenId, newOwner, "wrong-uid", salt);
    }

    function testTransferWithInvalidSaltFails() public {
        vm.prank(deployer);
        dpp.mintDPP(user, uid, publicMetadata, salt);

        tokenId = bytes32(0);

        vm.prank(user);
        vm.expectRevert(InvalidUID.selector);
        dpp.transferOwnershipWithUID(tokenId, newOwner, uid, "wrong-salt");
    }

    function testOnlyTokenOwnerCanCallTransferWithUID() public {
        vm.prank(deployer);
        dpp.mintDPP(user, uid, publicMetadata, salt);

        tokenId = bytes32(0);

        vm.prank(admin); // Not the owner
        vm.expectRevert(NotTokenOwner.selector);
        dpp.transferOwnershipWithUID(tokenId, newOwner, uid, salt);
    }
}
