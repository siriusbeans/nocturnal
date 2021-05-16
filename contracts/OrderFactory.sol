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

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {NoctInterface} from "./Interfaces/NoctInterface.sol";
import {OracleInterface} from "./Interfaces/OracleInterface.sol";
import {OrderInterface} from "./Interfaces/OrderInterface.sol";
import {Order} from "./Order.sol";
import {RewardsInterface} from "./Interfaces/RewardsInterface.sol";

contract OrderFactory {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    
    Counters.Counter public orderCounter;
    
    uint256 public platformVolume;
    uint256 internal constant bPDivisor = 10000;
    address WETH; 
    
    mapping(address => uint256) swapOrderID;
    mapping(address => address) swapPoolAddress;
    mapping(address => address) swapFromTokenAddress;
    mapping(address => address) swapToTokenAddress;
    mapping(address => uint256) swapFromTokenBalance;
    mapping(address => uint256) swapToTokenBalance;
    mapping(address => uint256) swapFromTokenValueInETH;
    mapping(address => uint256) swapLimitPrice;
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
    
    constructor(address _nocturnalFinance, address _WETH) public {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
        WETH = _WETH;
    }
    
    function createLimitOrder(
            address _swapPoolAddress, 
            address _swapFromTokenAddress, 
            address _swapToTokenAddress, 
            uint256 _swapFromTokenBalance, 
            uint256 _swapLimitPrice,
            uint256 _swapSlippage,
            bool _swapAbove,
            uint256 _swapSettlementGratuity) public {
        require((_swapFromTokenAddress == WETH) || (_swapToTokenAddress == WETH), "pool must contain WETH");
        require(ERC20(_swapFromTokenAddress).balanceOf(msg.sender) >= _swapFromTokenBalance);
        require((_swapSettlementGratuity >= 0) && (_swapSettlementGratuity < nocturnalFinance.depositRate().mul(100).div(bPDivisor))); // expressed in basis points
        Order nocturnalOrder = new Order("Nocturnal Order", "oNOCT"); 
        orderCounter.increment();
        
        swapOrderID[address(nocturnalOrder)] = orderCounter.current();
        swapPoolAddress[address(nocturnalOrder)] = _swapPoolAddress;
        swapFromTokenAddress[address(nocturnalOrder)] = _swapFromTokenAddress;
        swapToTokenAddress[address(nocturnalOrder)] = _swapToTokenAddress;
        swapFromTokenBalance[address(nocturnalOrder)] = _swapFromTokenBalance;
        swapLimitPrice[address(nocturnalOrder)] = _swapLimitPrice;
        swapAbove[address(nocturnalOrder)] = _swapAbove;
        swapSlippage[address(nocturnalOrder)] = _swapSlippage;
        swapSettlementGratuity[address(nocturnalOrder)] = _swapSettlementGratuity;

        OrderInterface(nocturnalFinance.orderAddress())._mint(msg.sender, orderCounter.current());
        
        pool = IUniswapV3Pool(_swapPoolAddress);        
        
        
        // Process:
        
        // 1)  Calculate dFee
        uint256 dFee = _swapFromTokenBalance.mul(nocturnalFinance.depositRate()).div(bPDivisor);

        // 2)  If fromToken is WETH, transfer dFee WETH to Staking.sol then Transfer fromTokenBalance-dFee fromToken to order
        if (_swapFromTokenAddress == WETH) {
            fromWETHCreate(_swapFromTokenAddress, dFee, address(nocturnalOrder), _swapFromTokenBalance, pool.token0() == _swapFromTokenAddress, _swapPoolAddress);
                 
        // 3)  If toToken is WETH, swap dFee for WETH and send it to Staking.sol then Transfer fromTokenBalance-dFee fromToken to order
        } else if ((_swapToTokenAddress == WETH) ) {
          toWETHCreate(_swapFromTokenAddress, dFee, address(nocturnalOrder), _swapFromTokenBalance, pool.token0() == _swapFromTokenAddress, _swapPoolAddress);
        }
        
        // update Order fromTokenBalance attribute for settlement
        swapFromTokenBalance[address(nocturnalOrder)] = _swapFromTokenBalance.sub(dFee);
        
        // emit events
        emit orderCreated(orderCounter.current(), address(nocturnalOrder), _swapSettlementGratuity);
    }

    function fromWETHCreate(address _swapFromTokenAddress, uint256 dFee, address orderAddress, uint256 _swapFromTokenBalance, bool fromToken0, address _swapPoolAddress) internal {
         // 2)  If fromToken is WETH, transfer dFee WETH to Staking.sol then Transfer fromTokenBalance-dFee fromToken to order
            require(ERC20(_swapFromTokenAddress).transferFrom(msg.sender, nocturnalFinance.sNoctAddress(), dFee), "creator to stakers dFee transfer failed");
            require(ERC20(_swapFromTokenAddress).transferFrom(msg.sender, orderAddress, _swapFromTokenBalance.sub(dFee)), "creator to order balance transfer failed");
            
            // get fromTokenBalance value in ETH for tracking platform volume
            if (fromToken0 == true) {
                // interpret price tick data accurately
                // this is not correct
                swapFromTokenValueInETH[orderAddress] = uint256(int256(OracleInterface(nocturnalFinance.oracleAddress()).getCurrentPrice(_swapPoolAddress)));
            } else {
                // interpret price tick data accurately
                // this is not correct
                swapFromTokenValueInETH[orderAddress] = uint256(int256(OracleInterface(nocturnalFinance.oracleAddress()).getCurrentPrice(_swapPoolAddress)));
            }  
    }

    function toWETHCreate(address _swapFromTokenAddress, uint256 dFee, address orderAddress, uint256 _swapFromTokenBalance, bool fromToken0, address _swapPoolAddress) internal {
        // 3)  If toToken is WETH, swap dFee for WETH and send it to Staking.sol then Transfer fromTokenBalance-dFee fromToken to order
        
            OrderInterface(nocturnalFinance.orderAddress()).orderSwap(_swapPoolAddress, nocturnalFinance.sNoctAddress(), fromToken0, int256(dFee), 0);
            require(ERC20(_swapFromTokenAddress).transferFrom(msg.sender, orderAddress, _swapFromTokenBalance.sub(dFee)), "creator to order balance transfer failed");
            
            // get fromTokenBalance value in ETH for tracking platform volume
            if (fromToken0 == true) {
                // interpret price tick data accurately
                // this is not correct
                swapFromTokenValueInETH[orderAddress] = uint256(int256(OracleInterface(nocturnalFinance.oracleAddress()).getCurrentPrice(_swapPoolAddress)));
            } else {
                // interpret price tick data accurately
                // this is not correct
                swapFromTokenValueInETH[orderAddress] = uint256(int256(OracleInterface(nocturnalFinance.oracleAddress()).getCurrentPrice(_swapPoolAddress)));
            }
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
        if (pool.token0() == fromTokenAddress) {
            // currentPrice = ???
            currentPrice = uint256(int256(OracleInterface(nocturnalFinance.oracleAddress()).getCurrentPrice(_address)));
        } else {
            // currentPrice = ???
            currentPrice = uint256(int256(OracleInterface(nocturnalFinance.oracleAddress()).getCurrentPrice(_address)));
        }
        
        if (above == true) {
            require(currentPrice >= limitPrice, "limit not met");
        } else if (above == false) {
            require(currentPrice <= limitPrice, "limit not met");
        }
        
        //========================================================//
      
        uint256 fromTokenBalance = swapFromTokenBalance[_address];
        uint256 settlementGratuity = swapSettlementGratuity[_address];
        address orderCreatorAddress = OrderInterface(nocturnalFinance.orderAddress()).ownerOf(swapOrderID[_address]);
        uint256 sFTVIE = swapFromTokenValueInETH[_address];
        // Process:
        
        // 1)  Calculate gratuity
        uint256 gratuity = fromTokenBalance.mul(settlementGratuity).div(bPDivisor);
        
        bool fromToken0;
        if (pool.token0() == fromTokenAddress) {
            fromToken0 = true;
        } else {
            fromToken0 = false;
        }
        
        // 2)  If fromToken is WETH, deduct gratuity from WETH and send to settler before performing the swap
        if (fromTokenAddress == WETH) {
            fromWETHSettle(fromTokenAddress, gratuity, poolAddress, _address, fromToken0, fromTokenBalance);
                 
        // 3)  If toToken is WETH, perform the swap and then deduct gratuity from WETH and send to settler
        } else if (swapToTokenAddress[_address] == WETH) {
            toWETHSettle( gratuity, poolAddress, _address, fromToken0, fromTokenBalance);
        }
        
        // update Order toTokenBalance attribute for order closure
        swapToTokenBalance[_address] = fromTokenBalance.sub(gratuity);
        // update Order fromTokenBalance attribute for order closure
        swapFromTokenBalance[_address] = 0;
        
        // set swap settle flag to true
        swapSettledFlag[_address] = true;
                
        // 4)  Distribute the NOCT rewards to the settler and the creator (for them to claim later?)
        //     USE MAPPING TO TRACK CLAIMABLE NOCT
        //     CIRCULATING SUPPLY IS CLAIMED NOCT + UNCLAIMED NOCT
        //     On front end, rewards owners will have option to claim or claim+stake automatically
        distributeNOCTRewards(sFTVIE, orderCreatorAddress);

        // increment platform volume tracker counter
        platformVolume.add(sFTVIE);
       
        // 6) emit events
        emit orderSettled(swapOrderID[_address], _address, settlementGratuity);
        emit platformVolumeUpdate(platformVolume);
    }

    function fromWETHSettle(address fromTokenAddress, uint256 gratuity, address poolAddress, address _address, bool fromToken0, uint256 fromTokenBalance) internal {
        OrderInterface(nocturnalFinance.orderAddress()).transferOrder(fromTokenAddress, msg.sender, gratuity);            
        OrderInterface(nocturnalFinance.orderAddress()).orderSwap(poolAddress, _address, fromToken0, int256(fromTokenBalance.sub(gratuity)), 0);  
    }

    function toWETHSettle(uint256 gratuity, address poolAddress, address _address, bool fromToken0, uint256 fromTokenBalance) internal {
        OrderInterface(nocturnalFinance.orderAddress()).orderSwap(poolAddress, msg.sender, fromToken0, int256(gratuity), 0);
        OrderInterface(nocturnalFinance.orderAddress()).orderSwap(poolAddress, _address, fromToken0, int256(fromTokenBalance.sub(gratuity)), 0);
       
    }

    function distributeNOCTRewards(uint256 sFTVIE, address orderCreatorAddress) internal {
         // 4)  Distribute the NOCT rewards to the settler and the creator (for them to claim later?)
        //     USE MAPPING TO TRACK CLAIMABLE NOCT
        //     CIRCULATING SUPPLY IS CLAIMED NOCT + UNCLAIMED NOCT
        //     On front end, rewards owners will have option to claim or claim+stake automatically
        
        // creator gets 88% of amount of NOCT equal to swapFromTokenValueInETH
        // rewards balance is updated, and rewards can be claimed at rewards.sol contract address
        // increment totalRewards by creator rewards
        uint256 creatorRewards = sFTVIE.mul(nocturnalFinance.rewardsFactor()).div(bPDivisor);
        NoctInterface(nocturnalFinance.noctAddress()).mintRewards(nocturnalFinance.rewardsAddress(), creatorRewards);
        RewardsInterface(nocturnalFinance.rewardsAddress()).unclaimedRewards(orderCreatorAddress).add(creatorRewards);
        RewardsInterface(nocturnalFinance.rewardsAddress()).totalRewards().add(creatorRewards);
        
        // settler gets 8% of amount of NOCT equal to swapFromTokenValueInETH
        // rewards balance is updated, and rewards can be claimed at rewards.sol contract address
        // increment total rewards by settler rewards
        uint256 settlerRewards = sFTVIE.sub(creatorRewards);
        NoctInterface(nocturnalFinance.noctAddress()).mintRewards(nocturnalFinance.rewardsAddress(), settlerRewards);
        RewardsInterface(nocturnalFinance.rewardsAddress()).unclaimedRewards(msg.sender).add(settlerRewards);
        RewardsInterface(nocturnalFinance.rewardsAddress()).totalRewards().add(settlerRewards);

    }
    
    function closeLimitOrder(address _address) public {
        require(OrderInterface(nocturnalFinance.orderAddress()).ownerOf(swapOrderID[_address]) == msg.sender, "only order owner can close an order");
        
        if (swapSettledFlag[_address] == true) {
            // transfer fromTokenBalance from order to msg.sender address
            OrderInterface(nocturnalFinance.orderAddress()).closeOrder(swapOrderID[_address], swapToTokenAddress[_address], msg.sender, swapToTokenBalance[_address]);
            // burn order
            OrderInterface(nocturnalFinance.orderAddress()).burn(swapOrderID[_address]);  
        } else {
            // transfer fromTokenBalance from order to msg.sender address
            require(ERC20(swapFromTokenAddress[_address]).transferFrom(_address, msg.sender, swapFromTokenBalance[_address]), "order to creator balance transfer failed");
            // burn order
            OrderInterface(nocturnalFinance.orderAddress()).burn(swapOrderID[_address]);  
        }
        
        // emit events
        emit orderClosed(swapOrderID[_address], _address);
    }

    function getOrderID(address _orderAddress) public view returns (uint256) {
        return swapOrderID[_orderAddress];
    }
    
    function getOrderPoolAddress(address _orderAddress) public view returns (address) {
        return swapPoolAddress[_orderAddress];
    }
    
    function getOrderFromTokenAddress(address _orderAddress) public view returns (address) {
        return swapFromTokenAddress[_orderAddress];
    }
    
    function getOrderFromTokenBalance(address _orderAddress) public view returns (uint256) {
        return swapFromTokenBalance[_orderAddress];
    }
    
    function getOrderToTokenAddress(address _orderAddress) public view returns (address) {
        return swapToTokenAddress[_orderAddress];
    }
    
    function getOrderToTokenBalance(address _orderAddress) public view returns (uint256) {
        return swapToTokenBalance[_orderAddress];
    }
    
    function getOrderLimitPrice(address _orderAddress) public view returns (uint256) {
        return swapLimitPrice[_orderAddress];
    }
    
    function getOrderLimitType(address _orderAddress) public view returns (bool) {
        return swapAbove[_orderAddress];
    }
    
    function getOrderSwapSlippage(address _orderAddress) public view returns (uint256) {
        return swapSlippage[_orderAddress];
    }
    
    function getOrderSettlementGratuity(address _orderAddress) public view returns (uint256) {
        return swapSettlementGratuity[_orderAddress];
    }
    
    function getOrderSettledFlag(address _orderAddress) public view returns (bool) {
        return swapSettledFlag[_orderAddress];
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
