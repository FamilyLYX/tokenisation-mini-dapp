// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/DPPNFTFactory.sol";

contract DPPNFTFactoryTest is Test {
    DPPNFTFactory public factory;

    address public deployer = address(0xABCD);
    address public initialOwner = address(0xBEEF);
    address public newOwner = address(0xCAFE);

    string public name = "Demo Product Pass";
    string public symbol = "DPP";
    string public uid = "UNIQUE-UID-123";
    string public publicMetadata = '{"name":"Product","description":"Info"}';
    bytes public encryptedMetadata = abi.encode("secret");

    function setUp() public {
        vm.startPrank(deployer);
        factory = new DPPNFTFactory();
        vm.stopPrank();
    }

    function testOnlyOwnerCanTransferOwnership() public {
        vm.prank(initialOwner);
        vm.expectRevert("DPPNFTFactory: caller is not the owner");
        factory.transferOwnership(newOwner);

        vm.prank(deployer);
        factory.transferOwnership(newOwner);
        assertEq(factory.owner(), newOwner);
    }

    function testTransferOwnershipZeroAddress() public {
        vm.prank(deployer);
        vm.expectRevert("DPPNFTFactory: new owner is the zero address");
        factory.transferOwnership(address(0));
    }

    function testCreateNFTAndRegister() public {
        vm.prank(deployer);
        address nftAddress = factory.createNFT(
            name,
            symbol,
            initialOwner,
            uid,
            publicMetadata,
            encryptedMetadata
        );

        // Confirm NFT is registered
        bool isRegistered = factory.isRegisteredNFT(nftAddress);
        assertTrue(isRegistered);

        // Confirm NFT is initialized correctly
        DPPNFT nft = DPPNFT(payable(nftAddress));
        assertEq(nft.owner(), initialOwner);
        assertEq(nft.getUIDHash(), keccak256(abi.encodePacked(uid)));
        assertEq(string(nft.getPublicMetadata()), publicMetadata);

        // Read encrypted metadata as the owner
        vm.prank(initialOwner);
        assertEq(nft.getEncryptedMetadata(), encryptedMetadata);
    }

    function testCreateNFTFailsWithZeroInitialOwner() public {
        vm.prank(deployer);
        vm.expectRevert("DPPNFTFactory: initialOwner is the zero address");
        factory.createNFT(
            name,
            symbol,
            address(0),
            uid,
            publicMetadata,
            encryptedMetadata
        );
    }
}
