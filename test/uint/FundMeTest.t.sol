// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";

import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract FundMeTest is Test {
    address USER = makeAddr("USER");

    FundMe private s_fundMe;
    address private s_priceFeedAddress;

    event FundedAmount(address indexed funder, uint256 indexed amount);
    event OwnerWithdrawn(address indexed owner, uint256 indexed amount);

    function setUp() external {
        HelperConfig config;

        DeployFundMe deployer = new DeployFundMe();
        (s_fundMe, config) = deployer.run();
        (s_priceFeedAddress,) = config.activeNetworkConfig();

        vm.deal(USER, 1 ether);
    }

    function testInitiallyThereHasZeroFundings() public {
        uint256 initialExpectedFunds = 0;
        uint256 initialActualFunds = s_fundMe.getBalance();

        assertEq(initialActualFunds, initialExpectedFunds);
        assertEq(initialActualFunds, address(s_fundMe).balance);
    }

    function testPriceFeedIsCorrect() public {
        address actualPriceFeedAddress = s_fundMe.getPriceFeed();

        assertEq(actualPriceFeedAddress, s_priceFeedAddress);
    }

    function testMinimumUSDValueIsCorrect() public {
        uint256 expectedMinimumUsdValue = 5e18;
        uint256 actualMinimumUsdValue = s_fundMe.getMinimumUSD();

        assertEq(actualMinimumUsdValue, expectedMinimumUsdValue);
    }

    function testInitialFundersLengthIsZero() public {
        uint256 expectedFundersLength = 0;
        uint256 actualFundersLength = s_fundMe.getFundersLength();

        assertEq(actualFundersLength, expectedFundersLength);
    }

    function testInitiallyRetrieveFunderAddressFails() public {
        vm.expectRevert();
        s_fundMe.getFunder(0);
    }

    function testInitiallyThereIsNoFunderWithAnyAmount() public {
        uint256 expectedFundedAmount = 0;
        uint256 actualFundedAmount = s_fundMe.getFunderFundedAmount(USER);

        assertEq(actualFundedAmount, expectedFundedAmount);
    }

    function testDeployerIsTheOwner() public {
        address expectedOwner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        address owner = s_fundMe.getOwner();

        assertEq(owner, expectedOwner);
    }

    function testUserCanFund() public {
        uint256 expectedFundersLength = 1;
        uint256 expectedFundedFunds = 0.004 ether;

        vm.startPrank(USER);
        s_fundMe.fund{value: expectedFundedFunds}();
        vm.stopPrank();

        address actualFunder = s_fundMe.getFunder(0);
        uint256 actualFundersLength = s_fundMe.getFundersLength();
        uint256 actualFundedFunds = s_fundMe.getFunderFundedAmount(actualFunder);

        assertEq(actualFunder, USER);
        assertEq(actualFundersLength, expectedFundersLength);
        assertEq(actualFundedFunds, expectedFundedFunds);
        assertEq(s_fundMe.getBalance(), expectedFundedFunds);
        assertEq(address(s_fundMe).balance, expectedFundedFunds);
    }

    function testWillFailedToFundInsufficientFunds() public {
        uint256 insufficientFunds = 0.002 ether;

        vm.startPrank(USER);
        vm.expectRevert(FundMe.FundMe__NotEnoughPaid.selector);
        s_fundMe.fund{value: insufficientFunds}();
        vm.stopPrank();
    }

    function testWillEmitAnEventOnSuccessfulFunding() public {
        uint256 fundAmount = 0.004 ether;

        vm.startPrank(USER);
        vm.expectEmit(true, true, false, false, address(s_fundMe));
        emit FundedAmount(USER, fundAmount);
        vm.recordLogs();
        s_fundMe.fund{value: fundAmount}();
        Vm.Log[] memory recordedLogs = vm.getRecordedLogs();
        vm.stopPrank();

        address emittedFunder = address(uint160(uint256(bytes32(recordedLogs[0].topics[1]))));
        uint256 emittedFunds = uint256(bytes32(recordedLogs[0].topics[2]));

        assertEq(emittedFunder, USER);
        assertEq(emittedFunds, fundAmount);
    }

    function testlowLevelReceiveWillDivertTheCalltoFundWithoutData() public {
        uint256 fundAmount = 0.004 ether;
        uint256 expectedFundersLength = 1;

        vm.startPrank(USER);
        (bool success,) = address(s_fundMe).call{value: fundAmount}("");
        vm.stopPrank();

        address actualFunder = s_fundMe.getFunder(0);
        uint256 actualFundersLength = s_fundMe.getFundersLength();
        uint256 actualFundedFunds = s_fundMe.getFunderFundedAmount(actualFunder);

        assertEq(success, true);
        assertEq(actualFunder, USER);
        assertEq(actualFundersLength, expectedFundersLength);
        assertEq(actualFundedFunds, fundAmount);
        assertEq(actualFundedFunds, s_fundMe.getBalance());
        assertEq(actualFundedFunds, address(s_fundMe).balance);
    }

    function testlowLevelFallbackWillDivertTheCalltoFundWithData() public {
        uint256 fundAmount = 0.004 ether;
        uint256 expectedFundersLength = 1;

        vm.startPrank(USER);
        (bool success,) = address(s_fundMe).call{value: fundAmount}(abi.encodeWithSignature("anything_invalid_data"));
        vm.stopPrank();

        address actualFunder = s_fundMe.getFunder(0);
        uint256 actualFundersLength = s_fundMe.getFundersLength();
        uint256 actualFundedFunds = s_fundMe.getFunderFundedAmount(actualFunder);

        assertEq(success, true);
        assertEq(actualFunder, USER);
        assertEq(actualFundersLength, expectedFundersLength);
        assertEq(actualFundedFunds, fundAmount);
    }

    modifier funded() {
        uint256 expectedFundedFunds = 0.004 ether;

        vm.startPrank(USER);
        s_fundMe.fund{value: expectedFundedFunds}();
        vm.stopPrank();
        _;
    }

    function testCannotWithdrawIfWithdrawerIsNotOwner() public funded {
        vm.prank(USER);
        vm.expectRevert(FundMe.FundMe__NotOwner.selector);
        s_fundMe.withdraw();
    }

    function testNoNeedToWithdrawIfBalanceIsZero() public {
        vm.prank(s_fundMe.getOwner());
        vm.expectRevert(FundMe.FundMe__NothingToWithdraw.selector);
        s_fundMe.withdraw();
    }

    function testOnlyOwnerCanWithdrawSuccessfully() public funded {
        address owner = s_fundMe.getOwner();

        vm.startPrank(owner);
        s_fundMe.withdraw();
        vm.stopPrank();

        uint256 updatedBalance = s_fundMe.getBalance();
        uint256 fundersLength = s_fundMe.getFundersLength();
        uint256 updatedFunderFundedAmountRecord = s_fundMe.getFunderFundedAmount(USER);

        assertEq(updatedBalance, 0);
        assertEq(fundersLength, 0);
        assertEq(updatedFunderFundedAmountRecord, 0);
        assertEq(updatedBalance, address(s_fundMe).balance);
        assertEq(updatedBalance, s_fundMe.getBalance());
        vm.expectRevert();
        s_fundMe.getFunder(0);
    }

    function testWillEmitAnEventOnSuccessfulWithdrawal() public funded {
        address owner = s_fundMe.getOwner();
        uint256 netFundAmount = s_fundMe.getBalance();

        vm.startPrank(owner);
        vm.expectEmit(true, true, false, false, address(s_fundMe));
        emit OwnerWithdrawn(owner, netFundAmount);
        vm.recordLogs();
        s_fundMe.withdraw();
        Vm.Log[] memory recordedLogs = vm.getRecordedLogs();
        vm.stopPrank();

        bytes32 ownerInEvent = recordedLogs[0].topics[1];
        address emittedOwner = address(uint160(uint256(ownerInEvent)));

        bytes32 fundsInEvent = recordedLogs[0].topics[2];
        uint256 emittedFunds = uint256(fundsInEvent);

        assertEq(emittedOwner, owner);
        assertEq(emittedFunds, netFundAmount);
    }

    function testMultipleFundersCanFundAndOnlyOwnerCanWithdraw() public {
        uint160 multipleFundersLength = 6;
        uint256 fundAmount = 0.5 ether;

        for (uint160 i = 1; i <= multipleFundersLength; i++) {
            hoax(address(i), fundAmount);
            s_fundMe.fund{value: fundAmount}();
        }

        uint256 startingOwnerBalance = s_fundMe.getOwner().balance;
        uint256 startingFundMeBalance = s_fundMe.getBalance(); // address(s_fundMe).balance : (alternative)

        vm.startPrank(s_fundMe.getOwner());
        s_fundMe.withdraw();
        vm.stopPrank();

        uint256 endingFundMeBalance = address(s_fundMe).balance;
        uint256 endingOwnerBalance = s_fundMe.getOwner().balance;
        uint256 totalFunding = (fundAmount * multipleFundersLength);

        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance, totalFunding);
        assertEq(endingOwnerBalance, (startingOwnerBalance + totalFunding));
    }

    function testGetPriceWorksCorrectly() public view {
        uint256 latestPrice = s_fundMe.getLatestEthAmountUsdValue();

        assert(latestPrice > 0);
    }
}
