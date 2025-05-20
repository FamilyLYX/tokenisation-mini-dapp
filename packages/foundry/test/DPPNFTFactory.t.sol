// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/DPPNFTFactory.sol";
import "../src/DPPNFT.sol";

contract DPPNFTFactoryTest is Test {
    DPPNFTFactory public factory;
    DPPNFT public implementation;

    address public deployer = address(0xABCD);
    address public initialOwner = address(0xBEEF);
    address public newOwner = address(0xCAFE);

    string public name = "Demo Product Pass";
    string public symbol = "DPP";

    // Metadata details (for minting in NFT)
    string public uid = "UNIQUE-UID-123";
    string public publicMetadata = '{"name":"Product","description":"Info"}';
    bytes public encryptedMetadata = abi.encode("secret");

    function setUp() public {
        vm.startPrank(deployer);

        // Deploy the implementation contract first
        implementation = new DPPNFT();

        // Deploy the factory with the implementation address
        factory = new DPPNFTFactory(address(implementation));

        vm.stopPrank();
    }

    function testOnlyOwnerCanTransferOwnership() public {
        vm.prank(initialOwner);
        vm.expectRevert("Ownable: caller is not the owner");
        factory.transferOwnership(newOwner);

        vm.prank(deployer);
        factory.transferOwnership(newOwner);
        assertEq(factory.owner(), newOwner);
    }

    function testTransferOwnershipZeroAddress() public {
        vm.prank(deployer);
        vm.expectRevert("Ownable: new owner is the zero address");
        factory.transferOwnership(address(0));
    }

    function testCreateNFTAndMintToken() public {
        vm.prank(deployer);
        address nftAddress = factory.createNFT(name, symbol, initialOwner);

        // Confirm NFT is registered
        bool isRegistered = factory.isRegisteredNFT(nftAddress);
        assertTrue(isRegistered);

        // Interact with the clone (DPPNFT)
        DPPNFT nft = DPPNFT(payable(nftAddress));

        // Mint a token inside the cloned NFT contract, by calling mintDPP as factory
        vm.prank(address(factory));
        nft.mintDPP(initialOwner, uid, publicMetadata, encryptedMetadata);

        // Retrieve tokenId similarly to mintDPP logic
        uint256 lastIndex = nft.nextTokenIndex() - 1;
        bytes32 tokenId = keccak256(
            abi.encodePacked(lastIndex, block.timestamp, initialOwner)
        );

        // Check that token owner is initialOwner
        assertEq(nft.tokenOwnerOf(tokenId), initialOwner);

        // Check UID hash
        bytes32 expectedUidHash = keccak256(abi.encodePacked(uid));
        assertEq(nft.getUIDHash(tokenId), expectedUidHash);

        // Check public metadata
        assertEq(string(nft.getPublicMetadata(tokenId)), publicMetadata);

        // Check encrypted metadata reading by owner
        vm.prank(initialOwner);
        assertEq(nft.getEncryptedMetadata(tokenId), encryptedMetadata);
    }

    function testCreateNFTFailsWithZeroInitialOwner() public {
        vm.prank(deployer);
        vm.expectRevert(InvalidInitialOwner.selector);
        factory.createNFT(name, symbol, address(0));
    }
}
