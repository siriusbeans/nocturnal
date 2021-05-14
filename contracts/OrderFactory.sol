pragma solidity ^0.6.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
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
    event orderCreated(uint256 _orderID, address _orderAddress, uint256 _settlementGratuity, uint256 _creatorRewards, uint256 _settlerRewards);
    event orderSettled(uint256 _orderID, address _orderAddress, uint256 _settlementGratuity, uint256 _creatorRewards, uint256 _settlerRewards);
    event orderClosed(uint256 _orderID, address _orderAddress);
    event rewardsPending(uint256 _pendingRewards);
    event rewardsTotal(uint256 _totalRewards);
    event orderModified(uint256 _orderID, address _orderAddress, uint256 _settlementGratuity, uint256 _creatorRewards, uint256 _settlerRewards);
    
    NocturnalFinanceInterface public nocturnalFinance;
    IUniswapV3Pool public pool;
    
    constructor(address _nocturnalFinance) public {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
        uint256 internal constant bPDivisor = 1000;
        address internal constant WETH = 0xd0a1e359811322d97991e03f863a0c30c2cf029c; // Kovan
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
        require((_swapFromTokenAddress == WETH) || (_swapToTokenAddress == WETH), "pool must contain WETH");
        require(ERC20(_swapFromTokenAddress).balanceOf(msg.sender) >= _swapFromTokenBalance )
        uint256 dRateBasisPoints = nocturnalFinance.depositRate();
        require((_swapSettlementGratuity >= 0) && (_swapSettlementGratuity < dRateBasisPoints.mul(100).div(bPDivisor)));
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
        
        
        // Process:
        
        // 1)  Calculate dFee
        uint256 dFee = _swapFromTokenBalance.mul(dRateBasisPoints).div(bPDivisor);      
        
        // BREAK STEPS 2 AND 3 INTO FUNCTION CALLS
        // REDUCE LOGIC / REPETITION
        
        pool = IUniswapV3Pool(_swapPoolAddress);
        
        bool fromToken0;
        if (pool.token0 == _swapFromTokenAddress) {
            fromToken0 = true;
        } else {
            fromToken0 = false;
        }
        
        // 2)  If fromToken is WETH, transfer dFee WETH to Staking.sol then Transfer fromTokenBalance-dFee fromToken to ERC721
        if ((_swapFromTokenAddress == WETH) {
            require(ERC20(_swapFromTokenAddress).transferFrom(msg.sender, nocturnalFinance.sNoctAddress(), dFee), "creator to stakers dFee transfer failed");
            require(ERC20(_swapFromTokenAddress).transferFrom(msg.sender, orderAddress, _swapFromTokenBalance-dFee), "creator to ERC721 balance transfer failed");
                 
        // 3)  If toToken is WETH, swap dFee for WETH and send it to Staking.sol then Transfer fromTokenBalance-dFee fromToken to ERC721
        } else if ((_swapToTokenAddress == WETH) && (fromToken0 == true)) {
            require(ERC20(_swapFromTokenAddress).transferFrom(msg.sender, address(this), dFee), "ERC721 to factory dfee transfer failed");
            pool.swap(address(this), true, dFee, 0); // fourth parameter is sqrtPriceLimitX96, unsure what this should be
            require(ERC20(_swapToTokenAddress).transfer(nocturnalFinance.sNoctAddress(), dFee), "factory to stakers dfee transfer failed");
            require(ERC20(_swapFromTokenAddress).transferFrom(msg.sender, ERC721.ownerOf(orderID), _swapFromTokenBalance-dFee), "creator to ERC721 balance transfer failed");
            
        } else if ((_swapToTokenAddress == WETH) && (fromToken0 == false)) {
            require(ERC20(_swapFromTokenAddress).transferFrom(msg.sender, address(this), dFee), "ERC721 to factory dfee transfer failed");
            pool.swap(address(this), true, dFee, 0); // fourth parameter is sqrtPriceLimitX96, unsure what this should be
            require(ERC20(_swapToTokenAddress).transfer(nocturnalFinance.sNoctAddress(), dFee), "factory to stakers dfee transfer failed");
            require(ERC20(_swapFromTokenAddress).transferFrom(msg.sender, ERC721.ownerOf(orderID), _swapFromTokenBalance-dFee), "creator to ERC721 balance transfer failed");
        }
        
        
        // 4)  Update rewards maps and emit events
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
               

        // Process:
        
        // 1)  Calculate gratuity
        uint256 gratuity = _swapFromTokenBalance.mul(settlementGratuity).div(bPDivisor);
        
        // BREAK STEPS 2 AND 3 INTO FUNCTION CALLS
        // REDUCE LOGIC / REPETITION
        
        pool = IUniswapV3Pool(poolAddress);
        
        bool fromToken0;
        if (pool.token0 == _swapFromTokenAddress) {
            fromToken0 = true;
        } else {
            fromToken0 = false;
        }
        
        // 2)  If fromToken is WETH, deduct gratuity from WETH and send to settler before performing the swap then send remainder to creator
        if ((_swapFromTokenAddress == WETH) && (fromToken0 == true)) {
            require(ERC20(_swapFromTokenAddress).transferFrom(_address, address(this), _swapFromTokenBalance), "ERC721 to factory transfer failed");
            require(ERC20(_swapFromTokenAddress).transfer(msg.sender, gratuity), "settler gratuity transfer failed");
            pool.swap(address(this), true, _swapFromTokenBalance, _swapFromTokenBalance.min(gratuity), 0); // fourth parameter is sqrtPriceLimitX96, unsure what this should be    
            require(ERC20(_swapToTokenAddress).transfer(ERC721.ownerOf(orderID), _swapFromTokenBalance.min(gratuity)), "creator balance transfer failed");
                   
        } else if ((_swapFromTokenAddress == WETH) && (fromToken0 == false)) {
            require(ERC20(_swapFromTokenAddress).transferFrom(_address, address(this), _swapFromTokenBalance), "ERC721 to factory transfer failed");
            require(ERC20(_swapFromTokenAddress).transfer(msg.sender, gratuity), "settler gratuity transfer failed");
            pool.swap(address(this), false, _swapFromTokenBalance, _swapFromTokenBalance.min(gratuity), 0); // fourth parameter is sqrtPriceLimitX96, unsure what this should be    
            require(ERC20(_swapToTokenAddress).transfer(ERC721.ownerOf(orderID), _swapFromTokenBalance.min(gratuity)), "creator balance transfer failed");
                 
        // 3)  If toToken is WETH, perform the swap and then deduct gratuity from WETH and send to settler then send remainder to creator
        } else if ((_swapToTokenAddress == WETH) && (fromToken0 == true)) {
            require(ERC20(_swapFromTokenAddress).transferFrom(_address, address(this), _swapFromTokenBalance), "ERC721 to factory transfer failed");
            pool.swap(address(this), true, _swapFromTokenBalance, 0); // fourth parameter is sqrtPriceLimitX96, unsure what this should be
            require(ERC20(_swapToTokenAddress).transfer(msg.sender, gratuity), "settler gratuity transfer failed");
            require(ERC20(_swapToTokenAddress).transfer(ERC721.ownerOf(orderID), gratuity), "settler gratuity transfer failed");
            
        } else if ((_swapToTokenAddress == WETH) && (fromToken0 == false)) {
            require(ERC20(_swapFromTokenAddress).transferFrom(_address, address(this), _swapFromTokenBalance), "ERC721 to factory transfer failed");
            pool.swap(address(this), false, _swapFromTokenBalance, 0); // fourth parameter is sqrtPriceLimitX96, unsure what this should be
            require(ERC20(_swapToTokenAddress).transfer(msg.sender, gratuity), "settler gratuity transfer failed");
            require(ERC20(_swapToTokenAddress).transfer(ERC721.ownerOf(orderID), gratuity), "settler gratuity transfer failed");
        }
                
        // 4)  Distribute the NOCT rewards to the settler and the creator
        require(ERC20(nocturnalFinance.noctAddress()).transferFrom(nocturnalFinance.noctAddress(), msg.sender, settlerRewards), "settler noct rewards transfer failed");
        require(ERC20(nocturnalFinance.noctAddress()).transferFrom(nocturnalFinance.noctAddress(), ERC721.ownerOf(orderID), creatorRewards), "creator noct rewards transfer failed");
        
        // 5)  burn ERC721
        ERC721._burn(orderID);  //  
        
        // 6)  Update rewards maps and emit events
        uint256 pendingRewards = creatorRewards.add(settlerRewards);
        RewardsInterface(nocturnalFinance.rewardsAddress()).pendingRewards().decrement(pendingRewards); 
        RewardsInterface(nocturnalFinance.rewardsAddress()).totalRewards().increment(pendingRewards);
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

        // transfer fromTokenBalance from ERC721 to msg.sender address
        require(ERC20(_swapFromTokenAddress).transferFrom(_address, msg.sender, _swapFromTokenBalance), "ERC721 to creator transfer failed");
        
        // burn ERC721
        ERC721._burn(orderID);  //  
        
        // deduct pending rewards from pending rewards accumulator map
        uint256 creatorRewards = swapCreatorRewards[_address];
        uint256 settlerRewards = swapSettlerRewards[_address];
        uint256 pendingRewards = creatorRewards.add(settlerRewards);
        RewardsInterface(nocturnalFinance.rewardsAddress()).pendingRewards().decrement(pendingRewards); 


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
