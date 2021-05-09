// SPDX-License-Identifier: MIT
pragma solidity ^0.6.7;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract ChainlinkGasPriceFeed {

    AggregatorV3Interface internal gasPriceFeed;  

    constructor() public {
        gasPriceFeed = AggregatorV3Interface(0x169E633A2D1E6c10dD91238Ba11c4A708dfEF37C);
    }

    function getGasPrice() public view returns (int) {
        (
            uint80 roundID, 
            int256 answer,
            uint256 startedAt,
            uint256 timeStamp,
            uint80 answeredInRound
        ) = gasPriceFeed.latestRoundData();
        return answer;
    }    
}
