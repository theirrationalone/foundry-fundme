// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";

import {FundMe} from "../../src/FundMe.sol";

contract FundMeInvariantHandler is Test {
    FundMe private s_fundMe;

    constructor(address _fundMeAddress) {
        s_fundMe = FundMe(payable(_fundMeAddress));
    }

    /**
     *
     * @param _fundSeed Seed for funding.
     * @param _senderSeed Sender to send transaction and fund in crowd.
     *
     * @notice Anyone can fund but only owner can withdraw!
     */
    function fund(uint96 _fundSeed, address _senderSeed) public {
        uint256 minimumUSD = s_fundMe.getMinimumUSD();
        uint256 fundAmount = bound(_fundSeed, minimumUSD, type(uint96).max);

        hoax(_senderSeed, fundAmount);
        s_fundMe.fund{value: fundAmount}();
    }

    /**
     *
     * @notice Anyone can fund but only owner can withdraw!
     */
    function withdraw() public {
        if (address(s_fundMe).balance <= 0) {
            return;
        }

        address owner = s_fundMe.getOwner();
        vm.startPrank(owner);
        s_fundMe.withdraw();
        vm.stopPrank();
    }
}
