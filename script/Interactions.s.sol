// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract FundFundMe is Script {
    function fundFundMe(address fundMe, uint256 _fundAmount) public {
        vm.startBroadcast();
        FundMe(payable(fundMe)).fund{value: _fundAmount}();
        vm.stopBroadcast();
    }

    function run() external {
        address recentFundMe = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        fundFundMe(recentFundMe, 0.004 ether);
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address fundMe) public {
        HelperConfig config = new HelperConfig();
        (, uint256 privateKey) = config.activeNetworkConfig();

        vm.startBroadcast(privateKey);
        FundMe(payable(fundMe)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address recentFundMe = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMe(recentFundMe);
    }
}
