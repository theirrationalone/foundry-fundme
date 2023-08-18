// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract FundFundMe is Script {
    function fundFundMe(address fundMe, uint256 _fundAmount) public {
        FundMe(payable(fundMe)).fund{value: _fundAmount}();
    }

    function run() external {
        HelperConfig config = new HelperConfig();
        (, uint256 privateKey) = config.activeNetworkConfig();

        address recentFundMe = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);

        vm.startBroadcast(privateKey);
        fundFundMe(recentFundMe, 0.003 ether);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address fundMe) public {
        FundMe(payable(fundMe)).withdraw();
    }

    function run() external {
        HelperConfig config = new HelperConfig();
        (, uint256 privateKey) = config.activeNetworkConfig();

        address recentFundMe = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);

        vm.startBroadcast(privateKey);
        withdrawFundMe(recentFundMe);
        vm.stopBroadcast();
    }
}
