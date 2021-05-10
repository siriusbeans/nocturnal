// SPDX-License-Identifier: MIT
pragma solidity 0.6.6;

interface NocturnalFinanceInterface {
    function noctAddress() external view returns (address);
    function oracleAddress() external view returns (address);
    function pickWinnerAddress() external view returns (address);
    function rewardsAddress() external view returns (address);
    function limitOrdersAddress() external view returns (address);
    function poolsAddress() external view returns (address);
    function gasPriceFeedAddress() external view returns (address);
    function setLotteryVolume() external view returns (uint256);
    function setLotteryBatchSize() external view returns (uint256);
}
