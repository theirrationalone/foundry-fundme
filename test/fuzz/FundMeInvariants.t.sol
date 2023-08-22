// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";

import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {FundMeInvariantHandler} from "./FundMeInvariantHandler.t.sol";

contract FundMeInvariants is StdInvariant, Test {
    FundMe private s_fundMe;
    uint256 private s_ownerPreviousBalance;

    function setUp() external {
        DeployFundMe deployer = new DeployFundMe();
        (s_fundMe,) = deployer.run();

        s_ownerPreviousBalance = s_fundMe.getOwner().balance;

        FundMeInvariantHandler handler = new FundMeInvariantHandler(address(s_fundMe));

        targetContract(address(handler));
    }

    function invariant_mustUpdateFundMeContractAndOwnerBalanceOnFundingAndWithdrawal() public {
        // Test only condition that matches and remains identical in all tests into targetContract's functions.

        // Ge in assert refers to "Greater than or Equals to".
        assertGe(s_fundMe.getOwner().balance, s_ownerPreviousBalance);

        // assertEq(s_fundMe.getFundersLength(), 0);    // Why can't we test this out??? (Answer: can be different in different calls of different functions).
    }

    function invariant_gettersAlwaysGetPassed() public {
        s_fundMe.getBalance();
        s_fundMe.getOwner();
        s_fundMe.getPriceFeed();
        s_fundMe.getMinimumUSD();
        s_fundMe.getFundersLength();
        s_fundMe.getLatestEthAmountUsdValue();

        for (uint160 i = 0; i < type(uint8).max; i++) {
            vm.txGasPrice(1000e18);
            s_fundMe.getFunderFundedAmount(address(i));
        }
    }
}
