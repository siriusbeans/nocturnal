// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.1.0/contracts/math/SafeMath.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {NoctInterface} from "./Interfaces/NoctInterface.sol";
import {OrderFactory} from "./Interfaces/OrderFactory.sol";
import {PickWinner} from "./Interfaces/PickWinner.sol";

// NEXT:
// this contract will track and transfer rewards
// all NOCT will be held in this contract (after team & testnet allocation removed)
// all platform generated ETH will be held in this contract

contract Rewards is Ownable {
    using SafeMath for uint256;
    
    mapping(address => uint256) public rewards;
    
    constructor() public {
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
}
