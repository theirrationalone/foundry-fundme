// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";

import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract FundMeTest is Test {
    address USER = makeAddr("USER");

    FundMe private s_fundMe;
    address private s_priceFeedAddress;

    function setUp() external {
        HelperConfig config;

        DeployFundMe deployer = new DeployFundMe();
        (s_fundMe, config) = deployer.run();
        (s_priceFeedAddress,) = config.activeNetworkConfig();

        vm.deal(USER, 1 ether);
    }
}
