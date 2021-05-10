// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.1.0/contracts/math/SafeMath.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {NoctInterface} from "./Interfaces/NoctInterface.sol";
import {GasPriceFeed} from "./Interfaces/GasPriceFeedInterface.sol";
import {LimitOrders} from "./Interfaces/LimitOrders.sol";
import {PickWinner} from "./Interfaces/PickWinner.sol";

// NEXT:
// this contract will handle the generation of rewards
// NOCT rewards will be minted after the following events:
// public function calls for lottery winner selection
// public function call for limit order execution
// public function call for 

contract Rewards is Ownable {
    using SafeMath for uint256;
    
    constructor() public {
    }
    
    function mintLimitOrderExecutionRewards() external {
    //require(msg.sender == )
    }
    
    function mintSwappedTokenWithdrawalRewards() external {
    //require(msg.sender == )
    }
    
    function mintLotteryFunctionRewards() external {
    //require(msg.sender == )
    }
    
    function mintOracleUpdateRewards() external {
    //require(msg.sender == )
    }
