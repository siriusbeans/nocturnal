pragma solidity ^0.6.6;

interface NocturnalFinanceInterface {
    function oracleAddress() external view returns (address);
    function rewardsAddress() external view returns (address);
    function orderFactoryAddress() external view returns (address);
    function feeRateAddress() external view returns (address);
    function noctAddress() external view returns (address);
    function sNoctAddress() external view returns (address);
}
