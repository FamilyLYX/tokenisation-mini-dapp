// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/DPPNFT.sol";

contract DPPNFTTest is Test {
    DPPNFT public dpp;

    address public deployer = address(0xDEADBEEF);
    address public user = address(0xBEEF);
    address public newOwner = address(0xCAFE);

    string public name = "Demo Product Pass";
    string public symbol = "DPP";

    string public uid = "UNIQUE-UID-123";
    string public salt = "RANDOM-SALT";
    string public publicMetadata = '{"name":"Product","description":"Info"}';

    bytes32 public uidHash;
    bytes32 public newUidHash;
    bytes32 public tokenId;
    bytes32 public constant DPP_METADATA_KEY = keccak256("DPP_METADATA");

    function setUp() public {
        dpp = new DPPNFT();

        uidHash = keccak256(abi.encodePacked(salt, uid));
        newUidHash = keccak256(abi.encodePacked("newsalt", "new-uid"));

        // Simulate the deployer calling initialize to become owner
        vm.prank(deployer);
        dpp.initialize(name, symbol, deployer);
    }

    function testOwnerCanMintDPP() public {
        vm.prank(deployer);
        dpp.mintDPP(user, publicMetadata, uidHash);

        tokenId = bytes32(0);

        address owner = dpp.tokenOwnerOf(tokenId);
        assertEq(owner, user);
    }

    function testOnlyOwnerCanMint() public {
        vm.expectRevert("Ownable: caller is not the owner");
        dpp.mintDPP(user, publicMetadata, uidHash);
    }

    function testTransferFunctionIsDisabled() public {
        vm.prank(deployer);
        dpp.mintDPP(user, publicMetadata, uidHash);

        tokenId = bytes32(0);

        vm.prank(user);
        vm.expectRevert(TransferNotAllowed.selector);
        dpp.transfer(user, newOwner, tokenId, true, "");
    }

    function testTransferWithUIDRotation_Success() public {
        vm.prank(deployer);
        dpp.mintDPP(user, publicMetadata, uidHash);

        tokenId = bytes32(0);

        vm.prank(user);
        dpp.transferWithUIDRotation(
            tokenId,
            newOwner,
            "",
            salt,
            uid,
            newUidHash
        );

        address owner = dpp.tokenOwnerOf(tokenId);
        assertEq(owner, newOwner);
    }

    function testTransferWithUIDRotation_InvalidUID() public {
        vm.prank(deployer);
        dpp.mintDPP(user, publicMetadata, uidHash);

        tokenId = bytes32(0);

        vm.prank(user);
        vm.expectRevert(InvalidUID.selector);
        dpp.transferWithUIDRotation(
            tokenId,
            newOwner,
            "",
            "wrong-salt",
            "wrong-uid",
            newUidHash
        );
    }

    function testTransferWithUIDRotation_NotTokenOwner() public {
        vm.prank(deployer);
        dpp.mintDPP(user, publicMetadata, uidHash);

        tokenId = bytes32(0);

        vm.prank(deployer); // not the token owner
        vm.expectRevert(NotTokenOwner.selector);
        dpp.transferWithUIDRotation(
            tokenId,
            newOwner,
            "",
            salt,
            uid,
            newUidHash
        );
    }

    function testFetchStoredMetadataAndUIDHash() public {
        vm.prank(deployer);
        bytes32 uidHash = keccak256(abi.encodePacked(salt, uid));
        dpp.mintDPP(user, publicMetadata, uidHash);

        tokenId = bytes32(0);

        // Fetch public JSON metadata
        bytes memory metadataBytes = dpp.getDataForTokenId(
            tokenId,
            DPP_METADATA_KEY
        );
        string memory fetchedMetadata = string(metadataBytes);
        assertEq(fetchedMetadata, publicMetadata);

        // Fetch and verify UID hash
        bytes memory storedUIDBytes = dpp.getDataForTokenId(
            tokenId,
            keccak256("DPP_UID_Hash")
        );
        bytes32 storedUIDHash = abi.decode(storedUIDBytes, (bytes32));
        assertEq(storedUIDHash, uidHash);
    }
}
