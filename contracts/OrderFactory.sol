/*                              $$\                                             $$\                                                         
                                $$ |                                            $$ |                                                  
$$$$$$$\   $$$$$$\   $$$$$$$\ $$$$$$\   $$\   $$\  $$$$$$\  $$$$$$$\   $$$$$$\  $$ |     
$$  __$$\ $$  __$$\ $$  _____|\_$$  _|  $$ |  $$ |$$  __$$\ $$  __$$\  \____$$\ $$ |    
$$ |  $$ |$$ /  $$ |$$ /        $$ |    $$ |  $$ |$$ |  \__|$$ |  $$ | $$$$$$$ |$$ |     
$$ |  $$ |$$ |  $$ |$$ |        $$ |$$\ $$ |  $$ |$$ |      $$ |  $$ |$$  __$$ |$$ |     
$$ |  $$ |\$$$$$$  |\$$$$$$$\   \$$$$  |\$$$$$$  |$$ |      $$ |  $$ |\$$$$$$$ |$$ |      
\__|  \__| \______/  \_______|   \____/  \______/ \__|      \__|  \__| \_______|\__|     
*/

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/Uniswap/uniswap-v3-core/blob/main/contracts/interfaces/IUniswapV3Pool.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {NoctInterface} from "./Interfaces/NoctInterface.sol";
import {OracleInterface} from "./Interfaces/OracleInterface.sol";
import {OrderInterface} from "./Interfaces/OrderInteface.sol";
import {RewardsInterface} from "./Interfaces/Rewards.sol";

contract OrderFactory {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    
    uint256 public orderCounter;
    uint256 public platformVolume;
    Counter.counters public orderCounter;
    Counter.counters public platformVolume;
    
    mapping(address => uint256) swapOrderID;
    mapping(address => address) swapPoolAddress;
    mapping(address => address) swapFromTokenAddress;
    mapping(address => address) swapToTokenAddress;
    mapping(address => uint256) swapFromTokenBalance;
    mapping(address => uint256) swapToTokenBalance;
    mapping(address => uint256) swapFromTokenValueInETH;
    mapping(address => uint256) swapToTokenLimitPrice;
    mapping(address => bool) swapAbove;
    mapping(address => uint256) swapSlippage;
    mapping(address => uint256) swapSettlementGratuity;
    mapping(address => bool) swapSettledFlag;
    
    // may include all attributes in events
    // someone may want to analyze trade data in future
    event orderCreated(uint256 _orderID, address _orderAddress, uint256 _settlementGratuity);
    event orderSettled(uint256 _orderID, address _orderAddress, uint256 _settlementGratuity);
    event orderClosed(uint256 _orderID, address _orderAddress);
    event orderModified(uint256 _orderID, address _orderAddress, uint256 _settlementGratuity);
    event platformVolumeUpdate(uint256 _volume);
    
    NocturnalFinanceInterface public nocturnalFinance;
    IUniswapV3Pool public pool;
    
    constructor(address _nocturnalFinance) public {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
        uint256 internal constant bPDivisor = 1000;  // 100th of a bip
        address internal constant WETH = 0xd0a1e359811322d97991e03f863a0c30c2cf029c; // Kovan, Rinkeby?
    }
    
    function createLimitOrder(
            address _swapPoolAddress, 
            address _swapFromTokenAddress, 
            address _swapToTokenAddress, 
            uint256 _swapFromTokenBalance, 
            uint256 _swapLimitPrice,
            bool _swapAbove,
            bool _swapFromToken0,
            uint256 _swapSettlementGratuity) public {
        require((_swapFromTokenAddress == WETH) || (_swapToTokenAddress == WETH), "pool must contain WETH");
        require(ERC20(_swapFromTokenAddress).balanceOf(msg.sender) >= _swapFromTokenBalance )
        uint256 dRateBasisPoints = nocturnalFinance.depositRate();
        require((_swapSettlementGratuity >= 0) && (_swapSettlementGratuity < dRateBasisPoints.mul(100).div(bPDivisor)));
        Order nocturnalOrder = new Order ("Nocturnal Order", "oNOCT"); 
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

        OrderInterface(nocturnalFinance.orderAddress())._mint(msg.sender, orderID);
        
        pool = IUniswapV3Pool(_swapPoolAddress);        
        bool fromToken0;
        if (pool.token0 == _swapFromTokenAddress) {
            fromToken0 = true;
        } else {
            fromToken0 = false;    
        }
        
        // Process:
        
        // 1)  Calculate dFee
        uint256 dFee = _swapFromTokenBalance.mul(dRateBasisPoints).div(bPDivisor);

        // 2)  If fromToken is WETH, transfer dFee WETH to Staking.sol then Transfer fromTokenBalance-dFee fromToken to order
        if ((_swapFromTokenAddress == WETH) {
            require(ERC20(_swapFromTokenAddress).transferFrom(msg.sender, nocturnalFinance.sNoctAddress(), dFee), "creator to stakers dFee transfer failed");
            require(ERC20(_swapFromTokenAddress).transferFrom(msg.sender, orderAddress, _swapFromTokenBalance.min(dFee)), "creator to order balance transfer failed");
            
            // get fromTokenBalance value in ETH for tracking platform volume
            if (fromToken0 == true) {
                // interpret price tick data accurately
                // this is not correct
                swapFromTokenValueInETH[orderAddress] = OracleInterface(nocturnalFinance.oracleAddress()).getCurrentPrice(_swapPoolAddress);;
            } else {
                // interpret price tick data accurately
                // this is not correct
                swapFromTokenValueInETH[orderAddress] = OracleInterface(nocturnalFinance.oracleAddress()).getCurrentPrice(_swapPoolAddress);;
            }           
                 
        // 3)  If toToken is WETH, swap dFee for WETH and send it to Staking.sol then Transfer fromTokenBalance-dFee fromToken to order
        } else if ((_swapToTokenAddress == WETH) ) {
            require(OrderInterface(nocturnalFinance.orderAddress()).orderSwap(poolAddress, nocturnalFinance.sNoctAddress(), fromToken0, dFee, 0), "creator to stakers fee transfer failed");
            require(ERC20(_swapFromTokenAddress).transferFrom(msg.sender, orderAddress, _swapFromTokenBalance.min(dFee)), "creator to order balance transfer failed");
            
            // get fromTokenBalance value in ETH for tracking platform volume
            if (fromToken0 == true) {
                // interpret price tick data accurately
                // this is not correct
                swapFromTokenValueInETH[orderAddress] = OracleInterface(nocturnalFinance.oracleAddress()).getCurrentPrice(_swapPoolAddress);;
            } else {
                // interpret price tick data accurately
                // this is not correct
                swapFromTokenValueInETH[orderAddress] = OracleInterface(nocturnalFinance.oracleAddress()).getCurrentPrice(_swapPoolAddress);;
            }
        }
        
        // update Order fromTokenBalance attribute for settlement
        swapFromTokenBalance[orderAddress] = _swapFromTokenBalance.min(dFee);
        
        // emit events
        emit orderCreated(orderID, orderAddress, _swapSettlementGratuity);
        emit rewardsPending(pendingRewards);
        emit rewardsTotal(totalRewards);
    }
    
    function settleLimitOrder(address _address) public {
        bool above = swapAbove[_address];
        uint256 limitPrice = swapLimitPrice[_address];
        address fromTokenAddress = swapFromTokenAddress[_address];
        address poolAddress = swapPoolAddress[_address];
        uint256 currentPrice;
        pool = IUniswapV3Pool(poolAddress);
        
        //========================================================//
        
        // oracle returns a tick accum value
        // the value of the limit returned by front end may 
        // need to be a function of token0 (fromToken or toToken?)
        if (pool.token0 == fromTokenAddress) {
            // currentPrice = ???
            currentPrice = OracleInterface(nocturnalFinance.oracleAddress()).getCurrentPrice(_address);
        } else {
            // currentPrice = ???
            currentPrice = OracleInterface(nocturnalFinance.oracleAddress()).getCurrentPrice(_address);
        }
        
        if (above == true) {
            require(currentPrice >= limitPrice, "limit not met");
        } else if (above == false) {
            require(currentPrice <= limitPrice, "limit not met");
        }
        
        //========================================================//

        uint256 orderID = swapOrderID[_address];      
        address fromTokenAddress = swapFromTokenAddress[_address];
        address toTokenAddress = swapToTokenAddress[_address];
        uint256 fromTokenBalance = swapFromTokenBalance[_address];
        uint256 slippage = swapSlippage[_address];
        uint256 settlementGratuity = swapSettlementGratuity[_address];
        address orderCreatorAddress = OrderInterface(nocturnalFinance.orderAddress()).ownerOf(orderID);
        address orderSettlerAddress = msg.sender;
        // Process:
        
        // 1)  Calculate gratuity
        uint256 gratuity = _swapFromTokenBalance.mul(settlementGratuity).div(bPDivisor);
        
        bool fromToken0;
        if (pool.token0 == _swapFromTokenAddress) {
            fromToken0 = true;
        } else {
            fromToken0 = false;
        }
        
        // 2)  If fromToken is WETH, deduct gratuity from WETH and send to settler before performing the swap
        if (_swapFromTokenAddress == WETH) {
            require(OrderInterface(nocturnalFinance.orderAddress()).orderTransfer(ERC20(_swapFromTokenAddress), msg.sender, gratuity), "order to settler gratuity transfer failed");            
            require(OrderInterface(nocturnalFinance.orderAddress()).orderSwap(poolAddress, _address, fromToken0, _swapFromTokenBalance.min(gratuity), 0), "order swap failed"); 
                 
        // 3)  If toToken is WETH, perform the swap and then deduct gratuity from WETH and send to settler
        } else if (_swapToTokenAddress == WETH) {
            require(OrderInterface(nocturnalFinance.orderAddress()).orderSwap(poolAddress, msg.sender, fromToken0, gratuity, 0), "order to settler gratuity transfer failed");
            require(OrderInterface(nocturnalFinance.orderAddress()).orderSwap(poolAddress, _address, fromToken0, _swapFromTokenBalance.min(gratuity), 0), "order swap failed");
        }
        
        // update Order toTokenBalance attribute for order closure
        swapToTokenBalance[orderAddress] = _swapToTokenBalance.min(gratuity);
        // update Order fromTokenBalance attribute for order closure
        swapFromTokenBalance[orderAddress] = 0;
        
        // set swap settle flag to true
        swapSettledFlag[_address] = true;
                
        // 4)  Distribute the NOCT rewards to the settler and the creator (for them to claim later?)
        //     USE MAPPING TO TRACK CLAIMABLE NOCT
        //     CIRCULATING SUPPLY IS CLAIMED NOCT + UNCLAIMED NOCT
        //     On front end, rewards owners will have option to claim or claim+stake automatically
        
        // creator gets 88% of amount of NOCT equal to swapFromTokenValueInETH
        // rewards balance is updated, and rewards can be claimed at rewards.sol contract address
        // increment totalRewards by creator rewards
        uint256 creatorRewards = swapFromTokenValueInETH[orderAddress].mul(nocturnalFinance.rewardsFactor()).div(bPDivisor);
        nocturnalFinance.noctAddress().mintRewards(settlerRewards, nocturnalFinance.rewardsAddress());
        RewardsInterface(nocturnalFinance.rewardsAddress()).unclaimedRewards[orderCreatorAddress].add(creatorRewards);
        RewardsInterface(nocturnalFinance.rewardsAddress()).totalRewards().increment(creatorRewards);
        
        // settler gets 8% of amount of NOCT equal to swapFromTokenValueInETH
        // rewards balance is updated, and rewards can be claimed at rewards.sol contract address
        // increment total rewards by settler rewards
        uint256 settlerRewards = swapFromTokenValueInETH[orderAddress].min(creatorRewards);
        nocturnalFinance.noctAddress().mintRewards(settlerRewards, nocturnalFinance.rewardsAddress());
        RewardsInterface(nocturnalFinance.rewardsAddress()).unclaimedRewards[orderSettlerAddress].add(settlerRewards);
        RewardsInterface(nocturnalFinance.rewardsAddress()).totalRewards().increment(settlerRewards);

        // increment platform volume tracker counter
        platformVolume.increment(swapFromTokenValueInETH[orderAddress]);
       
        // 6) emit events
        emit orderSettled(orderID, orderAddress, settlementGratuity);
        emit platformVolumeUpdate(platformVolume);
    }
    
    function closeLimitOrder(address _address) public {
        require(OrderInterface(nocturnalFinance.orderAddress()).ownerOf(swapOrderID[_address]) == msg.sender, "only order owner can close an order");
        
        if (swapSettledFlag[_address] == true) {
            // transfer fromTokenBalance from order to msg.sender address
            require(OrderInterface(nocturnalFinance.orderAddress()).closeOrder(swapOrderID[_address], swapToTokenAddress[_address], msg.sender, swapToTokenAddress[_address]), "order to creator balance transfer failed");
            // burn order
            OrderInterface(nocturnalFinance.orderAddress()).burn(swapOrderID[_address]);  
        } else {
            // transfer fromTokenBalance from order to msg.sender address
            require(ERC20(swapFromTokenAddress[_address]).transferFrom(_address, msg.sender, swapFromTokenBalance[_address]), "order to creator balance transfer failed");
            // burn order
            OrderInterface(nocturnalFinance.orderAddress()).burn(swapOrderID[_address]);  
        }
        
        // emit events
        emit orderClosed(orderID, _address);
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
    
    function getOrderToTokenBalance(address _orderAddress) public view returns (uint256) {
        return swapToTokenBalance[_address];
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
    
    function getOrderSettledFlag(address _orderAddress) public view returns (bool) {
        return swapSettledFlag[_address];
    }
    
    function modifyOrderSwapSlippage(address _orderAddress, uint256 _newSwapSlippage) public returns (uint256) {
        uint256 orderID = swapOrderID[_orderAddress];
        require(OrderInterface(nocturnalFinance.orderAddress()).ownerOf(orderID) == msg.sender, "only owner can modify an existing order");
        swapSlippage[_orderAddress] = _newSwapSlippage;
      
        uint256 settlementGratuity = swapSettlementGratuity[_orderAddress];
        
        emit orderModified(orderID, _orderAddress, settlementGratuity);      
    }
    
    function modifyOrderSettlementGratuity(address _orderAddress, uint256 _newSettlementGratuity) public returns (uint256) {
        uint256 orderID = swapOrderID[_orderAddress];
        require(OrderInterface(nocturnalFinance.orderAddress()).ownerOf(orderID) == msg.sender, "only owner can modify an existing order");
        swapSettlementGratuity[_orderAddress] = _newSettlementGratuity;
        
        
        emit orderModified(orderID, _orderAddress, _newSettlementGratuity);      
    }
}
