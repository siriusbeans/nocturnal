// SPDX-License-Identifier: MIT
pragma solidity 0.6.6;

interface NocturnalFinanceInterface {
    function noctAddress() external view returns (address);
    function oracleAddress() external view returns (address);
    function rewardsAddress() external view returns (address);
    function orderFactoryAddress() external view returns (address);
}
