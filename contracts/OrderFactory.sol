// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.1.0/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {NoctInterface} from "./Interfaces/NoctInterface.sol";
import {OracleInterface} from "./Interfaces/OracleInterface.sol";

// NEXT:
// track nocturnal trading volume within closeOrder() 
//

contract LimitOrders is ERC721, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    
    uint256 public orderCounter;
    Counter.counters public orderCounter;
    
    mapping(uint256 => address) swapPoolAddress;
    mapping(uint256 => address) swapFromTokenAddress;
    mapping(uint256 => address) swapToTokenAddress;
    mapping(uint256 => uint256) swapFromTokenBalance;
    mapping(uint256 => uint256) swapToTokenLimitPrice;
    mapping(uint256 => uint256) swapSlippage;
    mapping(uint256 => uint256) swapSettlementFee;
    
    // may only include order Address in the events...
    event orderCreated(address _orderAddress, address _fromTokenAddress, uint256 _fromTokenBalance, address _toTokenAddress, uint256 _settlementFee);
    event orderClosed(address _orderAddress, address _toTokenAddress, uint256 _toTokenBalance, address _fromTokenAddress, uint256 _settlementFee);
    
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance) public {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
    }
    
    function createLimitOrder(
            address _swapPoolAddress, 
            address _swapFromTokenAddress, 
            address _swapToTokenAddress, 
            uint256 _swapFromTokenBalance, 
            uint256 _swapLimitPrice,
            bool _swapAbove,
            uint256 _swapSlippage, 
            uint256 _swapSettlementFee) public {
        
        ERC721 nocturnalOrder = new ERC721 ("Nocturnal Order", "oNOCT"); 
        orderCounter.increment();
        uint256 orderID = orderCounter.current();
        
        swapPoolAddress[orderID] = _swapPoolAddress;
        swapFromTokenAddress[orderID] = _swapFromTokenAddress;
        swapToTokenAddress[orderID] = _swapToTokenAddress;
        swapFromTokenBalance[orderID] = _swapFromTokenBalance;
        swapLimitPrice[orderID] = _swapLimitPrice;
        swapAbove[orderID] = _swapAbove[orderID]
        swapSlippage[orderID] = _swapSlippage;
        swapSettlementFee[orderID] = _swapSettlementFee;
        
        _mint(msg.sender, orderID);
        
        // send "swap from" tokens to the ERC721 address
        // deduct nocturnal fee % from deposited tokens and send to nocturnal rewards contract
        
        emit orderCreated(address(nocturnalOrder));
    }
    
    function closeLimitOrder(uint256 _orderID) public {
        // compare order attributes and price oracle result and require limit is met
        address poolAddress = swapPoolAddress[orderID];
        address fromTokenAddress = swapFromTokenAddress[orderID];
        address toTokenAddress = swapToTokenAddress[orderID];
        uint256 fromTokenBalance = swapFromTokenBalance[orderID];
        uint256 limitPrice = swapLimitPrice[orderID];
        uint256 above = swapAbove[orderID];
        uint256 slippage = swapSlippage[orderID];
        uint256 settlementFee = swapSettlementFee[orderID];
        uint256 currentPrice = OracleInterface(nocturnalFinance.oracleAddress()).getCurrentPrice(poolAddress);
        
        if (swapAbove == true) {
            require(limitPrice >= currentPrice);
        } else if (swapAbove == false) {
            require(limitPrice <= currentPrice);
        }
        
        // perform the swap
        // deduct settlement fee
        // send settlement fee to closer
        // calculate and distribute NOCT rewards to closer and creator
        // emit orderClosed event with address
        // burn ERC721 
    }
}
