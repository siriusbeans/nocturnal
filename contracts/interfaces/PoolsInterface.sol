// SPDX-License-Identifier: MIT
pragma solidity 0.6.6;

interface PoolsInterface {
    function poolTitle(uint256) external view returns (string);
    function poolToken0Address(uint256) external view returns (address);
    function poolToken1Address(uint256) external view returns (address);
    function poolFee(uint256) external view returns (uint256);
}
