// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.1.0/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {NoctInterface} from "./Interfaces/NoctInterface.sol";
import {OrderFactoryInterface} from "./Interfaces/OrderFactoryInterface.sol";

// NEXT:
// Create rewardCalc() functions for:
//  1) Order Creator
//  2) Order Settler

contract Rewards {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    
    uint256 public pendingRewards;
    uint256 public totalRewards;
    Counter.counters public pendingRewards;
    Counter.counters public totalRewards;
    
    mapping(address => uint256) public claimedRewards;
    mapping(address => uint256) public unclaimedRewards;
    
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance) public {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
    }
    
    function claimRewards() public {
        address claimAddress = msg.sender;
        uint256 addressRewards = rewards[claimAddress];
        
        // transfer addressRewards to claimAddress
        
    }
    
    function checkRewards() public view returns (uint256) {
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
    
    function calculateOrderSettlerRewards() public returns (uint256) {
        require(msg.sender == nocturnalFinance.orderFactoryAddress());
        uint256 rewards;
        // compute rewards based on cirulating NOCT supply, total NOCT supply, and ????
        // **should the total supply at the time the order was created be considered here?**
        return(rewards);
    }
}
