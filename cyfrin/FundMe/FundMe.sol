// Get funds from users
// Withdraw funds
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    uint256 public minimumUsd = 5e18;       // 5 * 1e18

    function fund() public payable{
       require(getConversionRate(msg.value) >= minimumUsd, "didn't send enought eth");   // 1e18 = 1 eth
    }

    function withdraw() public {

    }

    function getPrice() public view returns (uint256){
        // Address 0x694AA1769357215DE4FAC081bf1f309aDC325306

        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);

        //price of ETH in terms of USD
        //2000.00000000
        (,int256 price,,,) = priceFeed.latestRoundData();
        
        // 2000.000000000000000000
        return uint256(price * 1e10);
    }
    function getConversionRate(uint256 ethAmount) public view returns(uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;

        // de ex pt 1 ETH
        // 2000.000000000000000000 * 1.000000000000000000 = ..36 zerouri / 1e18 => ethAmountInUsd e un nr cu 18 zerouri 

        return ethAmountInUsd;
    }

    function getVersion() public view returns(uint256){
        return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
    }
}