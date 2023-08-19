// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";

import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract InteractionsIntegrationTest is Test {
    FundMe private s_fundMe;

    function setUp() external {
        DeployFundMe deployer = new DeployFundMe();
        (s_fundMe,) = deployer.run();
    }

    function testFundFundMeIsWorkingWell() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(s_fundMe), 0.004 ether);

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(s_fundMe));
    }
}
