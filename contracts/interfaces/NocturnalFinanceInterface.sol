// SPDX-License-Identifier: MIT
pragma solidity 0.6.6;

interface NocturnalFinanceInterface {
    function noctAddress() external view returns (address);
    function oracleAddress() external view returns (address);
    function oracleTitle() external view returns (string);
    function oracleToken0Address() external view returns (address);
    function oracleToken1Address() external view returns (address);
    function oraclePoolFee() external view returns (uint256);
    function oracleIndexCounter() external view returns (uint256);
}
