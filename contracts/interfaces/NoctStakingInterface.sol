pragma solidity ^0.6.6;

interface NoctStakingInterface {
    function totalStaked() external view returns (uint256);
    function stake(uint256) external returns ();
    function withdraw(uint256) external returns ();
    function bRSLC(address) external view returns (uint256)
    function pendingETHRewards(address) external view returns (uint256)
    function claimETHRewards() external returns (); 
}
