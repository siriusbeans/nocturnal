// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {NoctInterface} from "./Interfaces/NoctInterface.sol";
import {OracleInterface} from "./Interfaces/OracleInterface.sol";

contract LimitOrders is ERC721 {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    
    uint256 public orderCounter;
    Counter.counters public orderCounter;
    
    mapping(address => uint256) swapOrderID;
    mapping(address => address) swapPoolAddress;
    mapping(address => address) swapFromTokenAddress;
    mapping(address => address) swapToTokenAddress;
    mapping(address => uint256) swapFromTokenBalance;
    mapping(address => uint256) swapToTokenLimitPrice;
    mapping(address => bool) swapAbove;
    mapping(address => uint256) swapSlippage;
    mapping(address => uint256) swapSettlementFee;
    mapping(address => uint256) swapCreatorRewards;
    mapping(address => uint256) swapSettlerRewards;
    
    // may only include order Address in the events...
    event orderCreated(uint256 _orderID, address _orderAddress, address _fromTokenAddress, uint256 _fromTokenBalance, address _toTokenAddress, uint256 _settlementFee, uint256 _creatorRewards, uint256 _settlerRewards);
    event orderSettled(uint256 _orderID, address _orderAddress, address _toTokenAddress, uint256 _toTokenBalance, address _fromTokenAddress, uint256 _settlementFee, uint256 _creatorRewards, uint256 _settlerRewards);
    event orderClosed(uint256 _orderID, address _orderAddress);
    
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
        address orderAddress = address(nocturnalOrder);
        
        swapOrderID[orderAddress] = orderID
        
        swapPoolAddress[orderAddress] = _swapPoolAddress;
        swapFromTokenAddress[orderAddress] = _swapFromTokenAddress;
        swapToTokenAddress[orderAddress] = _swapToTokenAddress;
        swapFromTokenBalance[orderAddress] = _swapFromTokenBalance;
        swapLimitPrice[orderAddress] = _swapLimitPrice;
        swapAbove[orderAddress] = _swapAbove[orderID];
        swapSlippage[orderAddress] = _swapSlippage;
        swapSettlementFee[orderAddress] = _swapSettlementFee;
        
        _mint(msg.sender, orderID);
        
        // send "swap from" tokens to the ERC721 address
        // deduct nocturnal fee % from deposited tokens and send to nocturnal rewards contract
        // calculate rewards for order creator
        // calculate rewards for order settler
        // add pending calculated rewards to pending rewards accumulator map
        
        emit orderCreated(orderID, orderAddress, _swapFromTokenAddress, _swapFromTokenBalance, _swapToTokenAddress, _swapSettlementFee);
    }
    
    function settleLimitOrder(address _address) public {
        // compare order attributes and price oracle result and require limit is met
        uint256 orderID = swapOrderID[_address];
        address poolAddress = swapPoolAddress[_address];
        address fromTokenAddress = swapFromTokenAddress[_address];
        address toTokenAddress = swapToTokenAddress[_address];
        uint256 fromTokenBalance = swapFromTokenBalance[_address];
        uint256 limitPrice = swapLimitPrice[_address];
        bool above = swapAbove[_address];
        uint256 slippage = swapSlippage[_address];
        uint256 settlementFee = swapSettlementFee[_address];
        uint256 creatorRewards = swapCreatorRewards[_address];
        uint256 settlerRewards = swapSettlerRewards[_address];
        uint256 currentPrice = OracleInterface(nocturnalFinance.oracleAddress()).getCurrentPrice(poolAddress);
        
        if (swapAbove == true) {
            require(currentPrice >= limitPrice, "limit not met");
        } else if (swapAbove == false) {
            require(currentPrice <= limitPrice, "limit not met");
        }
        
        // perform the swap
        // deduct settlement fee
        // obtain amount of token received in swap (for event)
        // send settlement fee to closer
        // track volume
        // calculate and distribute NOCT rewards to closer and creator
        // deduct NOCT pending rewards from NOCT pending rewards accumulator map
        // update NOCT circulating supply map accordingly
        // burn ERC721
        
        event orderSettled(_orderID, orderAddress, address toTokenAddress, uint256 _toTokenBalance, address fromTokenAddress, uint256 settlementFee, uint256 creator);
    }
    
    function closeLimitOrder(address _address) public {
        uint256 orderID = swapOrderID[_address];
        require(ERC721.ownerOf(tokenId) == msg.sender, "only order owner can close an order early");
        
        // transfer order asset to msg.sender address
        // an early withdraw penalty will be charged  ????
        // deduct pending rewards from pending rewards accumulator map
        // burn ERC721
        
        event orderClosed(uint256 tokenID, address _orderAddress);
    }

    function getOrderID(address _orderAddress) public view returns (uint256) {
        return swapOrderID[_address];
    }
    
    function getOrderPoolAddress(address _orderAddress) public view returns (address) {
        return swapPoolAddress[_address];
    }
    
    function getOrderFromTokenAddress(address _orderAddress) public view returns (address) {
        return swapFromTokenAddress[_address];
    }
    
    function getOrderFromTokenBalance(address _orderAddress) public view returns (uint256) {
        return swapFromTokenBalance[_address];
    }
    
    function getOrderToTokenAddress(address _orderAddress) public view returns (address) {
        return swapToTokenAddress[_address];
    }
    
    function getOrderLimitPrice(address _orderAddress) public view returns (address) {
        return swapToTokenLimitPrice[_address];
    }
    
    function getOrderLimitType(address _orderAddress) public view returns (bool) {
        return swapAbove[_address];
    }
    
    function getOrderSwapSlippage(uint256 _orderAddress) public view returns (uint256) {
        return swapSlippage[_address];
    }
    
    function getOrderSettlementFee(uint256 _orderAddress) public View returns (uint256) {
        return swapSettlementFee[_address];
    }
}
