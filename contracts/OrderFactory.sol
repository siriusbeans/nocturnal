pragma solidity ^0.6.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "https://github.com/Uniswap/uniswap-v3-periphery/blob/main/contracts/interfaces/ISwapRouter.sol";

import "https://github.com/Uniswap/uniswap-v3-core/blob/main/contracts/interfaces/IUniswapV3Pool.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {NoctInterface} from "./Interfaces/NoctInterface.sol";
import {OracleInterface} from "./Interfaces/OracleInterface.sol";
import {RewardsInterface} from "./Interfaces/RewardsInterface.sol";

contract OrderFactory is ERC721 {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    
    uint256 public orderCounter;
    Counter.counters public orderCounter;
    
    address internal constant UNISWAP_V3_SWAP_ROUTER = 0xbBca0fFBFE60F60071630A8c80bb6253dC9D6023; // Kovan
    
    mapping(address => uint256) swapOrderID;
    mapping(address => address) swapPoolAddress;
    mapping(address => address) swapFromTokenAddress;
    mapping(address => address) swapToTokenAddress;
    mapping(address => uint256) swapFromTokenBalance;
    mapping(address => uint256) swapToTokenLimitPrice;
    mapping(address => bool) swapAbove;
    mapping(address => uint256) swapSlippage;
    mapping(address => uint256) swapSettlementGratuity;
    mapping(address => uint256) swapCreatorRewards;
    mapping(address => uint256) swapSettlerRewards;
    
    // may include all attributes in events
    // someone may want to analyze trade data in future
    event orderCreated(uint256 _orderID, 
                       address _orderAddress, 
                       uint256 _settlementGratuity, 
                       uint256 _creatorRewards, 
                       uint256 _settlerRewards);
    event orderSettled(uint256 _orderID, 
                       address _orderAddress, 
                       uint256 _settlementGratuity, 
                       uint256 _creatorRewards, 
                       uint256 _settlerRewards);
    event orderClosed(uint256 _orderID, address _orderAddress);
    event rewardsPending(uint256 _pendingRewards);
    event rewardsTotal(uint256 _totalRewards);
    event orderModified(uint256 _orderID, address _orderAddress, uint256 _settlementGratuity, uint256 _creatorRewards, uint256 _settlerRewards);
    
    NocturnalFinanceInterface public nocturnalFinance;
    IUniswapV3Pool public pool;
    ISwapRouter public swapRouter;
    
    constructor(address _nocturnalFinance) public {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
        uint256 internal constant bPDivisor = 1000;
        address internal constant WETH = 0xd0a1e359811322d97991e03f863a0c30c2cf029c; // Kovan
        address internal constant UNISWAP_V3_SWAP_ROUTER = 0xbBca0fFBFE60F60071630A8c80bb6253dC9D6023;
    }
    
    function createLimitOrder(
            address _swapPoolAddress, 
            address _swapFromTokenAddress, 
            address _swapToTokenAddress, 
            uint256 _swapFromTokenBalance, 
            uint256 _swapLimitPrice,
            bool _swapAbove,
            uint256 _swapSlippage, 
            uint256 _swapSettlementGratuity) public {
        //require( creator balance is >= _swapFromTokenBalance )
        //require(_swapSettlementGratuity <= ) 
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
        swapSettlementGratuity[orderAddress] = _swapSettlementGratuity;
        
        // calculate NOCT rewards for order creator and settler
        uint256 (creatorRewards, settlerRewards) = RewardsInterface(nocturnalFinance.rewardsAddress()).calculateOrderRewards();
        swapCreatorRewards[orderAddress] = creatorRewards;
        swapSettlerRewards[orderAddress] = settlerRewards;

        _mint(msg.sender, orderID);
        

        // DEDUCT PLATFORM FEE FROM DEPOSIT
        // CONVERT TO WETH AND SEND TO STAKING CONTRACT
        // THEN SEND WHAT IS LEFT OF TOKEN TO ERC721
        
        // calculate FeeCalc rate value of fromTokenBalance
        uint256 dRateBasisPoints = nocturnalFinance.depositRate();
        uint256 dFee = _swapFromTokenBalance.mul(dRateBasisPoints).div(bPDivisor);
        
        
        
        if ((_swapFromTokenAddress == WETH) {
            // send dFee WETH to NoctStaking.sol
        } else if (_swapToTokenAddress == WETH) {
            // swap dFee _swapFromTokenAddess into WETH and send it to NoctStaking.sol
        } else {
            // swap dFee _swapFromTokenAddress into WETH and send it to NoctStaking.sol
            // _swapFromTokenAddress's WETH pool address is unknown
        }
      
      
                            
        // send remaining "swap from" tokens to the ERC721 address
        ERC20 token = ERC20(_swapFromTokenAddress);
        // must ensure the below operation occurs, always
        require(token.transferFrom(ERC721.ownerOf(orderID), orderAddress, fromTokenBalance.sub(dFee)), "order creation failed:  tokens did not reach order ERC721");
        
        
        // add pending calculated rewards to pending rewards accumulator map
        uint256 pendingRewards = creatorRewards.add(settlerRewards);
        RewardsInterface(nocturnalFinance.rewardsAddress()).pendingRewards().increment(pendingRewards);  //
        
        emit orderCreated(orderID, orderAddress, _swapSettlementGratuity, creatorRewards, settlerRewards);
        emit rewardsPending(pendingRewards);
        emit rewardsTotal(totalRewards);
    }
    
    function settleLimitOrder(address _address) public {
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
        uint256 settlementGratuity = swapSettlementGratuity[_address];
        uint256 creatorRewards = swapCreatorRewards[_address];
        uint256 settlerRewards = swapSettlerRewards[_address];
               

        
        // use pool.swap() to swap fromTokenBalance to toTokenBalance         
        
        // deduct settlementGratuity percentage from toTokenBalance and swap to ETH
        
        // calculate gratuity rate value of toTokenBalance
        uint256 gratuity = _swapFromTokenBalance.mul(settlementGratuity).div(bPDivisor);
        


        if ((_swapFromTokenAddress == WETH) {
            // send gratuity WETH to NoctStaking.sol
        } else if (_swapToTokenAddress == WETH) {
            // swap gratuity _swapFromTokenAddess into WETH and send it to NoctStaking.sol
        } else {
            // swap gratuity _swapFromTokenAddress into WETH and send it to NoctStaking.sol
            // _swapFromTokenAddress's WETH pool address is unknown
        }
        
       
        
        // send settlementGratuity to settler
        ERC20 token = ERC20(WETH);
        require(token.transfer(msg.sender, ), "gratuity transfer failed")
        
        // distribute NOCT rewards to settler and creator
        ERC20 token = ERC20(tA);
        require(token.balanceOf(msg.sender) >= amount, "insufficent NOCT balance");
        require(token.transferFrom(msg.sender, address(this), amount), "staking failed");
        
        // deduct NOCT pending rewards from NOCT pending rewards accumulator map
        uint256 pendingRewards = creatorRewards.add(settlerRewards);
        RewardsInterface(nocturnalFinance.rewardsAddress()).pendingRewards().decrement(pendingRewards); 
        
        // update NOCT circulating supply map accordingly
        RewardsInterface(nocturnalFinance.rewardsAddress()).totalRewards().increment(pendingRewards);
        
        

        
        // burn ERC721
        // use _burn()
        
        
        
        
        emit orderSettled(orderID, orderAddress, settlementGratuity, creatorRewards, settlerRewards);
        emit rewardsPending(pendingRewards);
        emit rewardsTotal(totalRewards);
    }
    
    function closeLimitOrder(address _address) public {
        uint256 orderID = swapOrderID[_address];
        require(ERC721.ownerOf(orderID) == msg.sender, "only order owner can close an order early");
        address fromTokenAddress = swapFromTokenAddress[_address];
        uint256 creatorRewards = swapCreatorRewards[_address];
        uint256 settlerRewards = swapSettlerRewards[_address];
        
        
        
        // transfer fromTokenAddress from ERC721 to msg.sender address
        // use transferFrom() 
        
        
        
        // deduct pending rewards from pending rewards accumulator map
        uint256 creatorRewards = swapCreatorRewards[_address];
        uint256 settlerRewards = swapSettlerRewards[_address];
        uint256 pendingRewards = creatorRewards.add(settlerRewards);
        RewardsInterface(nocturnalFinance.rewardsAddress()).pendingRewards().decrement(pendingRewards); 
        
        
        
        // burn ERC721
        // use _burn()
        
        
        
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
    
    function getOrderSettlementGratuity(address _orderAddress) public view returns (uint256) {
        return swapSettlementGratuity[_address];
    }
    
    function getOrderCreatorRewards(address _orderAddress) public view returns (uint256) {
        return swapCreatorRewards[_address];
    }
    
    function getOrderSettlerRewards(address _orderAddress) public view returns (uint256) {
        return swapSettlerRewards[_address];
    }
    
    function modifyOrderSwapSlippage(address _orderAddress, uint256 _newSwapSlippage) public returns (uint256) {
        uint256 orderID = swapOrderID[_orderAddress];
        require(ERC721.ownerOf(orderID) == msg.sender, "only owner can modify an existing order");
        swapSlippage[_orderAddress] = _newSwapSlippage;
        
        uint256 settlementGratuity = swapSettlementGratuity[_orderAddress];
        uint256 creatorRewards = swapCreatorRewards[_orderAddress];
        uint256 settlerRewards = swapSettlerRewards[_orderAddress];
        
        emit orderModified(orderID, _orderAddress, settlementGratuity, creatorRewards, settlerRewards);      
    }
    
    function modifyOrderSettlementGratuity(address _orderAddress, uint256 _newSettlementGratuity) public returns (uint256) {
        uint256 orderID = swapOrderID[_orderAddress];
        require(ERC721.ownerOf(orderID) == msg.sender, "only owner can modify an existing order");
        swapSettlementGratuity[_orderAddress] = _newSettlementGratuity;
        
        uint256 settlementGratuity = swapSettlementGratuity[_orderAddress];
        uint256 creatorRewards = swapCreatorRewards[_orderAddress];
        uint256 settlerRewards = swapSettlerRewards[_orderAddress];
        
        emit orderModified(orderID, _orderAddress, _newSettlementGratuity, creatorRewards, settlerRewards);      
    }
}
