// SPDX-License-Identifier: MIT
pragma solidity 0.6.6;

interface OrerFactoryInterface {
    function getCurrentPrice(address) external view returns (int24);
}
