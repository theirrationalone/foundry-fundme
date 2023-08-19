// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";

import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {FundMe} from "../../src/FundMe.sol";

contract DeployFundMeTest is Test {
    DeployFundMe deployer;

    function setUp() external {
        deployer = new DeployFundMe();
    }

    function testDeployFundMeScriptWorksAsIntended() public {
        (FundMe fundMe, HelperConfig config) = deployer.run();

        assertEq(address(fundMe), address(FundMe(payable(address(fundMe)))));
        assertEq(address(config), address(HelperConfig(address(config))));
    }
}
