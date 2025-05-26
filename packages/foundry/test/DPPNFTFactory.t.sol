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

    function setUp() public {
        vm.startPrank(deployer);

        // Deploy the implementation contract first
        implementation = new DPPNFT();

        // ✅ Deploy the factory with implementation AND admin address
        factory = new DPPNFTFactory(address(implementation), deployer);

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
}
