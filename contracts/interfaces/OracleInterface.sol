pragma solidity ^0.6.6;

interface OracleInterface {
    function getCurrentPrice(address) external view returns (int24);
    function getTokens(address) external view returns (address, address);
}
