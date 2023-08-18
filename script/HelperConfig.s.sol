// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.m.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address priceFeedAddress;
        uint256 privateKey;
    }

    NetworkConfig public activeNetworkConfig;

    uint8 private DECIMALS = 8;
    int256 private constant INITIAL_ANSWER = 2000e8;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaNetworkConfigs();
        } else if (block.chainid == 5) {
            activeNetworkConfig = getGoerliNetworkConfigs();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetNetworkConfigs();
        } else {
            activeNetworkConfig = createOrGetAnvilNetworkConfigs();
        }
    }

    function getGoerliNetworkConfigs() public view returns (NetworkConfig memory) {
        return NetworkConfig(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e, vm.envUint("PRIVATE_KEY"));
    }

    function getSepoliaNetworkConfigs() public view returns (NetworkConfig memory) {
        return NetworkConfig(0x694AA1769357215DE4FAC081bf1f309aDC325306, vm.envUint("PRIVATE_KEY"));
    }

    function getMainnetNetworkConfigs() public view returns (NetworkConfig memory) {
        return NetworkConfig(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419, vm.envUint("PRIVATE_KEY"));
    }

    function createOrGetAnvilNetworkConfigs() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeedAddress != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast(vm.envUint("ANVIL_PRIVATE_KEY"));
        MockV3Aggregator priceFeed = new MockV3Aggregator(DECIMALS,INITIAL_ANSWER);
        vm.stopBroadcast();

        return NetworkConfig(address(priceFeed), vm.envUint("ANVIL_PRIVATE_KEY"));
    }
}
