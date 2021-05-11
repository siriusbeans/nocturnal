// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.1.0/contracts/math/SafeMath.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {NoctInterface} from "./Interfaces/NoctInterface.sol";
import {OrderFactoryInterface} from "./Interfaces/OrderFactoryInterface.sol";
import {PickWinnerInterface} from "./Interfaces/PickWinnerInterface.sol";

// NEXT:
// Create rewardCalc() functions for:
//  1) Order Creator
//  2) Order Closer
//  3) Lottery Function Caller

contract Rewards is Ownable {
    using SafeMath for uint256;
    
    mapping(address => uint256) public rewards;
    
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance) public {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
    }
    
    function claimRewards() public {
        address claimAddress = msg.sender;
        uint256 addressRewards = rewards[claimAddress];
        
        // transfer addressRewards to claimAddress
        
    }
    
    function checkRewards() public view return (uint256) {
        address claimAddress = msg.sender;
        uint256 addressRewards = rewards[claimAddress];
        return(addressRewards);
    } 
    
    function calculateOrderCreatorRewards(uint256 _swapFromTokenBalance, uint256 _swapSettlementFee) public returns (uint256) {
        require(msg.sender == nocturnalFinance.orderFactoryAddress());
        uint256 rewards;
        // compute rewards based on swapFromTokenBalance, circulating NOCT supply, total NOCT supply, and swapSettlementFee
        return(rewards);
    }
    
    function calculateOrderCloserRewards() public returns (uint256) {
        require(msg.sender == nocturnalFinance.orderFactoryAddress());
        uint256 rewards;
        // compute rewards based on cirulating NOCT supply, total NOCT supply, and ????
        return(rewards);
    }
    
    function calculateLotteryRewards() public returns (uint256) {
        require(msg.sender == nocturnalFinance.orderFactoryAddress());
        uint256 rewards;
        // compute rewards based on circulating NOCT supply, total NOCT supply, and ????
        return(rewards);
    }
}
