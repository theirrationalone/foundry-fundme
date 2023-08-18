// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract FundFundMe is Script {
    function fundFundMe(address fundMe, uint256 _fundAmount) public {
        FundMe(payable(fundMe)).fund{value: _fundAmount}();
    }

    function run() external {
        HelperConfig config = new HelperConfig();
        (address priceFeedAddress, uint256 privateKey) = config.activeNetworkConfig();

        vm.startBroadcast(privateKey);
        FundMe fundMe = new FundMe(priceFeedAddress);
        fundFundMe(address(fundMe), 0.003 ether);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address fundMe) public {
        FundMe(payable(fundMe)).withdraw();
    }

    function run() external {
        HelperConfig config = new HelperConfig();
        (address priceFeedAddress, uint256 privateKey) = config.activeNetworkConfig();

        vm.startBroadcast(privateKey);
        FundMe fundMe = new FundMe(priceFeedAddress);
        fundMe.fund{value: 1 ether}();
        withdrawFundMe(address(fundMe));
        vm.stopBroadcast();
    }
}
