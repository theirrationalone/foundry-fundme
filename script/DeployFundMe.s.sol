// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig config = new HelperConfig();
        (address priceFeedAddress, uint256 privateKey) = config.activeNetworkConfig();

        vm.startBroadcast(privateKey);
        FundMe fundMe = new FundMe(priceFeedAddress);
        vm.stopBroadcast();

        return fundMe;
    }
}
