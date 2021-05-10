// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.1.0/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {NoctInterface} from "./Interfaces/NoctInterface.sol";

// NEXT:
// this must be written so that a single wallet can set multiple limit orders simultaneously
// that is with the same token pair, or various token pairs
// how will the limit orders be tracked?  mappings?  
// how can multiple orders be stored in a single address mapping?
// mapping to track volume ?  
// need volume tracked within contracts for lotto start require statement

contract LimitOrders is ERC721, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    
    uint256 public orderCounter;
    Counter.counters public orderCounter;
    
    mapping(uint256 => address) swapPoolAddress;
    mapping(uint256 => address) swapFromTokenAddress;
    mapping(uint256 => address) swapToTokenAddress;
    mapping(uint256 => uint256) swapFromTokenBalance;
    mapping(uint256 => uint256) swapToLimitPrice;
    mapping(uint256 => uint256) swapSlippage;
    mapping(uint256 => uint256) swapSettlementFee;
    
    constructor() public ERC721 ("Nocturnal Order", "oNOCT") {
    }
    
    function createLimitOrder(
            address _swapPoolAddress, 
            address _swapFromTokenAddress, 
            address _swapToTokenAddress, 
            uint256 _swapFromTokenBalance, 
            uint256 _swapToLimitPrice, 
            uint256 _swapSlippage, 
            uint256 _swapsettlementFee) public returns (uint256) {
        
        orderCounter.increment();
        uint256 orderID = orderCounter.current();
        
        swapPoolAddress[orderID] = _swapPoolAddress;
        swapFromTokenAddress[orderID] = _swapFromTokenAddress;
        swapToTokenAddress[orderID] = _swapToTokenAddress;
        swapFromTokenBalance[orderID] = _swapFromTokenBalance;
        swapToLimitPrice[orderID] = _swapToLimitPrice;
        swapSlippage[orderID] = _swapSlippage;
        swapSettlementFee[orderID] = _swapsettlementFee;
        
        _mint(msg.sender, tokenID);
        
        return(orderID);
    }
    
    function settleLimitOrder(uint256 _orderID, ) public {
        
    }
}
