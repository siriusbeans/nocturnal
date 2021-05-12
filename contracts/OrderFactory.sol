// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {NoctInterface} from "./Interfaces/NoctInterface.sol";
import {OracleInterface} from "./Interfaces/OracleInterface.sol";
import {RewardsInterface} from "./Interfaces/RewardsInterface.sol";

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
    
    // may only include order Address in the events
    // or may include all order attributes for analytics
    event orderCreated(uint256 _orderID, address _orderAddress, uint256 _settlementFee, uint256 _creatorRewards, uint256 _settlerRewards);
    event orderSettled(uint256 _orderID, address _orderAddress, uint256 _settlementFee, uint256 _creatorRewards, uint256 _settlerRewards);
    event orderClosed(uint256 _orderID, address _orderAddress);
    event rewardsPending(uint256 _pendingRewards);
    event rewardsTotal(uint256 _totalRewards);
    event orderModified(uint256 _orderID, address _orderAddress, uint256 _settlementFee, uint256 _creatorRewards, uint256 _settlerRewards);
    
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
        swapAbove[orderAddress] = _swapAbove;
        swapSlippage[orderAddress] = _swapSlippage;
        swapSettlementFee[orderAddress] = _swapSettlementFee;
        
        swapSettlerRewards[orderAddress] = _swapSettlerRewards;
        
        _mint(msg.sender, orderID);
        
        
        
        
        // send "swap from" tokens to the ERC721 address
        
        // deduct nocturnal fee % from deposited tokens, swap for ETH, and send to staker addresses
        
        // deposited token to be traded will need to be converted to ETH value
        // so if pool token0 / token1 is not WETH, logic must recognize this, and somehow convert deposited token to ETH
        
        
        
        
        
        // calculate NOCT rewards for order creator and settler
        uint256 (creatorRewards, settlerRewards) = RewardsInterface(nocturnalFinance.rewardsAddress()).calculateOrderRewards();
        swapCreatorRewards[orderAddress] = creatorRewards;
        swapSettlerRewards[orderAddress] = settlerRewards;
       
        // add pending calculated rewards to pending rewards accumulator map
        uint256 pendingRewards = creatorRewards.add(settlerRewards);
        RewardsInterface(nocturnalFinance.rewardsAddress()).pendingRewards().increment(pendingRewards);  //
        
        emit orderCreated(orderID, orderAddress, _swapSettlementFee, creatorRewards, settlerRewards);
        emit rewardsPending(pendingRewards);
        emit rewardsTotal(totalRewards);
    }
    
    function settleLimitOrder(address _address) public {
        // compare order attributes and price oracle result and require limit is met
        bool above = swapAbove[_address];
        uint256 limitPrice = swapLimitPrice[_address];
        uint256 currentPrice = OracleInterface(nocturnalFinance.oracleAddress()).getCurrentPrice(_address);
        if (swapAbove == true) {
            require(currentPrice >= limitPrice, "limit not met");
        } else if (swapAbove == false) {
            require(currentPrice <= limitPrice, "limit not met");
        }
        
        uint256 orderID = swapOrderID[_address];
        address poolAddress = swapPoolAddress[_address];
        address fromTokenAddress = swapFromTokenAddress[_address];
        address toTokenAddress = swapToTokenAddress[_address];
        uint256 fromTokenBalance = swapFromTokenBalance[_address];
        uint256 slippage = swapSlippage[_address];
        uint256 settlementFee = swapSettlementFee[_address];
        uint256 creatorRewards = swapCreatorRewards[_address];
        uint256 settlerRewards = swapSettlerRewards[_address];
        
        
        
        
        
        // perform the swap after deducting settlement fee in ETH
        // obtain amount of token received in swap (for event)
        // uint256 toTokenBalance = 
        // send settlement fee (in ETH) to settler
        // distribute NOCT rewards to closer and creator
        
        
        
        
        
        // deduct NOCT pending rewards from NOCT pending rewards accumulator map
        uint256 pendingRewards = creatorRewards.add(settlerRewards);
        RewardsInterface(nocturnalFinance.rewardsAddress()).pendingRewards().decrement(pendingRewards); 
        
        // update NOCT circulating supply map accordingly
        RewardsInterface(nocturnalFinance.rewardsAddress()).totalRewards().increment(pendingRewards);
        
        
        
        // burn ERC721
        
        
        
        
        emit orderSettled(orderID, orderAddress, settlementFee, creatorRewards, settlerRewards);
        emit rewardsPending(pendingRewards);
        emit rewardsTotal(totalRewards);
    }
    
    function closeLimitOrder(address _address) public {
        uint256 orderID = swapOrderID[_address];
        require(ERC721.ownerOf(orderID) == msg.sender, "only order owner can close an order early");
        
        uint256 creatorRewards = swapCreatorRewards[_address];
        uint256 settlerRewards = swapSettlerRewards[_address];
        
        
        
        
        // transfer order asset to msg.sender address
        // an early withdraw penalty will be charged  ????
        
        
        
        
        // deduct pending rewards from pending rewards accumulator map
        uint256 creatorRewards = swapCreatorRewards[_address];
        uint256 settlerRewards = swapSettlerRewards[_address];
        uint256 pendingRewards = creatorRewards.add(settlerRewards);
        RewardsInterface(nocturnalFinance.rewardsAddress()).pendingRewards().decrement(pendingRewards); 
        
        
        
        // burn ERC721
        
        
        
        emit orderClosed(orderID, _address);
        emit rewardsPending(pendingRewards);
        emit rewardsTotal(totalRewards);
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
    
    function getOrderLimitPrice(address _orderAddress) public view returns (uint256) {
        return swapToTokenLimitPrice[_address];
    }
    
    function getOrderLimitType(address _orderAddress) public view returns (bool) {
        return swapAbove[_address];
    }
    
    function getOrderSwapSlippage(address _orderAddress) public view returns (uint256) {
        return swapSlippage[_address];
    }
    
    function getOrderSettlementFee(address _orderAddress) public view returns (uint256) {
        return swapSettlementFee[_address];
    }
    
    function getOrderCreatorRewards(address _orderAddress) public view returns (uint256) {
        return swapCreatorRewards[_address];
    }
    
    function getOrderSettlerRewards(address _orderAddress) public view returns (uint256) {
        return swapSettlerRewards[_address];
    }
    
    // tihs may or may not be a good idea
    // if this could be used nefariously to aggressively
    // settle bulk orders in order to later dump NOCt
    // in order to dump NOCT price, then it should not be a feature
    function modifyOrderLimitPrice(address _orderAddress, uint256 _newLimitPrice) public returns (uint256) {
        // deduct a modification fee in ETH
        // send to Rewards.sol
        uint256 orderID = swapOrderID[_orderAddress];
        require(ERC721.ownerOf(orderID) == msg.sender, "only owner can modify an existing order");
        swapLimitPrice[_orderAddress] = _newLimitPrice;
        
        uint256 settlementFee = swapSettlementFee[_orderAddress];
        uint256 creatorRewards = swapCreatorRewards[_orderAddress];
        uint256 settlerRewards = swapSettlerRewards[_orderAddress];
        
        emit orderModified(orderID, _orderAddress, settlementFee, creatorRewards, settlerRewards);
    }
    
    // this should be modifiable 
    // maybe add attribute to erc721 that counts unsuccessful settlements due to slippage
    // owner oberves order was not settled, sees counter incrememnted, adjusts slippage accordingly
    function modifyOrderSwapSlippage(address _orderAddress, uint256 _newSwapSlippage) public returns (uint256) {
        // deduct a modification fee in ETH
        // send to Rewards.sol
        uint256 orderID = swapOrderID[_orderAddress];
        require(ERC721.ownerOf(orderID) == msg.sender, "only owner can modify an existing order");
        swapSlippage[_orderAddress] = _newSwapSlippage;
        
        uint256 settlementFee = swapSettlementFee[_orderAddress];
        uint256 creatorRewards = swapCreatorRewards[_orderAddress];
        uint256 settlerRewards = swapSettlerRewards[_orderAddress];
        
        emit orderModified(orderID, _orderAddress, settlementFee, creatorRewards, settlerRewards);      
    }
    
    // this should be modifiable imo
    function modifyOrderSettlementFee(address _orderAddress, uint256 _newSettlementFee) public returns (uint256) {
        // deduct a modification fee in ETH
        // send to Rewards.sol
        uint256 orderID = swapOrderID[_orderAddress];
        require(ERC721.ownerOf(orderID) == msg.sender, "only owner can modify an existing order");
        swapSettlementFee[_orderAddress] = _newSettlementFee;
        
        uint256 settlementFee = swapSettlementFee[_orderAddress];
        uint256 creatorRewards = swapCreatorRewards[_orderAddress];
        uint256 settlerRewards = swapSettlerRewards[_orderAddress];
        
        emit orderModified(orderID, _orderAddress, _newSettlementFee, creatorRewards, settlerRewards);      
    }
}
