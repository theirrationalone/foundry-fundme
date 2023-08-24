// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";

import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    function setUp() external {
        // nothing to do...
    }

    function testIntegratedInteractionBetweenFundAndWithdraw() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.run();

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.run();
    }
}
