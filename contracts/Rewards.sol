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
    
    function calculateOrderRewards(uint256 _swapFromTokenBalance) public returns (uint256, uint256) {
        require(msg.sender == nocturnalFinance.orderFactoryAddress());
        uint256 orderCreatorRewards;
        uint256 orderSettlerRewards;
        uint256 orderRewards;
        // compute rewards based on swapFromTokenBalance value in ETH, current pendingRewards, current totalRewards, and total NOCT supply
        
        // Condition:  As totalRewards + pendingRewards + orderRewards approaches totalSupply, orderRewards must
        //             get smaller, such that totalRewards + pendingRewards + orderRewards never is equal to totalSupply
        
        return(orderCreatorRewards, orderSettlerRewards);
    }
}
