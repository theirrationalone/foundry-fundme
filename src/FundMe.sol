// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import {PriceConverter} from "./PriceConverter.sol";

contract FundMe {
    using PriceConverter for uint256;

    error FundMe__NotEnoughPaid();
    error FundMe__NotOwner();
    error FundMe__NothingToWithdraw();
    error FundMe__WithdrawalFailed();

    uint256 private constant MINIMUM_USD = 5 * 1e18;
    address[] private s_funders;
    mapping(address funder => uint256 fund) private s_fundedFunds;

    address private immutable i_owner;
    AggregatorV3Interface private immutable i_priceFeed;

    event FundedAmount(address indexed funder, uint256 indexed amount);
    event OwnerWithdrawn(address indexed owner, uint256 indexed amount);

    modifier onlyOwner(address _sender) {
        if (_sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    modifier validPayment(uint256 _payment) {
        if (msg.value.getConversionRate(i_priceFeed) < MINIMUM_USD) {
            revert FundMe__NotEnoughPaid();
        }

        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    constructor(address _priceFeedAddress) {
        i_priceFeed = AggregatorV3Interface(_priceFeedAddress);
        i_owner = msg.sender;
    }

    function fund() public payable validPayment(msg.value) {
        s_funders.push(msg.sender);
        s_fundedFunds[msg.sender] = msg.value;

        emit FundedAmount(msg.sender, msg.value);
    }

    function withdraw() public onlyOwner(msg.sender) {
        if (address(this).balance <= 0) {
            revert FundMe__NothingToWithdraw();
        }

        address[] memory funders = s_funders;
        uint256 fundersLength = funders.length;

        for (uint256 i = 0; i < fundersLength; i++) {
            s_fundedFunds[funders[i]] = 0;
        }

        s_funders = new address[](0);

        uint256 netBalance = address(this).balance;

        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");

        if (!success) {
            revert FundMe__WithdrawalFailed();
        }

        emit OwnerWithdrawn(msg.sender, netBalance);
    }

    function getPriceFeed() external view returns (address) {
        return address(i_priceFeed);
    }

    function getMinimumUSD() external pure returns (uint256) {
        return MINIMUM_USD;
    }

    function getFundersLength() external view returns (uint256) {
        return s_funders.length;
    }

    function getFunder(uint256 _funderIndex) external view returns (address) {
        return s_funders[_funderIndex];
    }

    function getFunderFundedAmount(address _funderAddress) external view returns (uint256) {
        return s_fundedFunds[_funderAddress];
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getLatestEthAmountUsdValue() public view returns (uint256) {
        return PriceConverter.getPrice(i_priceFeed);
    }
}
