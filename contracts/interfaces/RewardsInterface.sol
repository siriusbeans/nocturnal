// SPDX-License-Identifier: MIT
pragma solidity 0.6.6;

interface OrerFactoryInterface {
    function claimRewards() external returns ();
    function checkRewards() external view returns (uint256);
    function calculateOrderCreatorRewards(uint256, uint256) external view returns (uint256);
    function calculateOrderSettlerRewards() external view returns (uint256);
    function pendingRewards() external view returns ();
    function totalRewards() external view returns ();
}
