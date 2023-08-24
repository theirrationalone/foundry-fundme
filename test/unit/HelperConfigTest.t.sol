// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";

import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {MockV3Aggregator} from "../mocks/MockV3Aggregator.m.sol";

contract HelperConfigTest is Test {
    HelperConfig config;

    function setUp() external {
        config = new HelperConfig();
    }

    function testHelperConfigSetsCorrectConfiguration() public {
        address sepoliaPriceFeedAddress = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
        address goerliPriceFeedAddress = 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e;
        address mainnetPriceFeedAddress = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
        uint256 myPrivateKey = vm.envUint("PRIVATE_KEY");
        uint256 anvilPrivateKey = vm.envUint("ANVIL_PRIVATE_KEY");

        HelperConfig.NetworkConfig memory sepoliaConfig = config.getSepoliaNetworkConfigs();
        assertEq(sepoliaConfig.priceFeedAddress, sepoliaPriceFeedAddress);
        assertEq(sepoliaConfig.privateKey, myPrivateKey);

        HelperConfig.NetworkConfig memory goerliConfig = config.getGoerliNetworkConfigs();
        assertEq(goerliConfig.priceFeedAddress, goerliPriceFeedAddress);
        assertEq(goerliConfig.privateKey, myPrivateKey);

        HelperConfig.NetworkConfig memory mainnetConfig = config.getMainnetNetworkConfigs();
        assertEq(mainnetConfig.priceFeedAddress, mainnetPriceFeedAddress);
        assertEq(mainnetConfig.privateKey, myPrivateKey);

        HelperConfig.NetworkConfig memory anvilConfig = config.createOrGetAnvilNetworkConfigs();
        assertEq(anvilConfig.priceFeedAddress, address(MockV3Aggregator(anvilConfig.priceFeedAddress)));
        assertEq(anvilConfig.privateKey, anvilPrivateKey);

        (address priceFeedAddress, uint256 pvtKey) = config.activeNetworkConfig();
        assertEq(anvilConfig.priceFeedAddress, priceFeedAddress);
        assertEq(anvilConfig.privateKey, pvtKey);

        HelperConfig anotherConfig = new HelperConfig();
        (address anotherPriceFeedAddress,) = anotherConfig.activeNetworkConfig();

        assert(anotherPriceFeedAddress != priceFeedAddress);
    }
}
