// SPDX-License-Identifier: MIT
pragma solidity 0.6.6;

interface OrerFactoryInterface {
    function claimRewards() external returns ();
    function checkRewards() external view returns (uint256);
    function calculateOrderRewards(uint256) external view returns (uint256, uint256);
    function pendingRewards() external view returns (uint256);
    function totalRewards() external view returns (uint256);
    function claimedRewards(address) external view returns (uint256);
    function unclaimedRewards(address) external view returns (uint256);
}
