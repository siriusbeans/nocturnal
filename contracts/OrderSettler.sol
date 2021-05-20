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

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {NoctInterface} from "./Interfaces/NoctInterface.sol";
import {OracleInterface} from "./Interfaces/OracleInterface.sol";
import {OrderInterface} from "./Interfaces/OrderInterface.sol";
import {RewardsInterface} from "./Interfaces/RewardsInterface.sol";
import {OrderFactoryInterface} from "./Interfaces/OrderFactoryInterface.sol";
import {OrderTransferInterface} from "./Interfaces/OrderTransferInterface.sol";

contract OrderSettler {
    using SafeMath for uint256;
    
    uint256 public platformVolume;
    uint256 internal constant bPDivisor = 10000;  // 100th of a bip
    address WETH; 
    
    // may include all attributes in events
    // someone may want to analyze trade data in future
    event orderSettled(uint256 _orderID, address _orderAddress, uint256 _settlementGratuity);
    event platformVolumeUpdate(uint256 _volume);
    
    NocturnalFinanceInterface public nocturnalFinance;
    IUniswapV3Pool public pool;
    
    constructor(address _nocturnalFinance, address _WETH) {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
        WETH = _WETH;
    }
    
    function settleLimitOrder(address _address) external {
        require(msg.sender == nocturnalFinance.orderFactoryAddress(), "caller is not order factory");
        bool above = OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapAbove(_address);
        uint256 limitPrice = OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapLimitPrice(_address);
        address fromTokenAddress = OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapFromTokenAddress(_address);
        address poolAddress = OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapPoolAddress(_address);
        uint256 currentPrice;
        pool = IUniswapV3Pool(poolAddress);
        
        // the value of the limit returned by front end 
        // is a function of token0 (fromToken or toToken)
        if (pool.token0() == fromTokenAddress) {
            currentPrice = OracleInterface(nocturnalFinance.oracleAddress()).getCurrentPrice(_address);
        } else {
            // obtain the reciprocal of below value
            currentPrice = OracleInterface(nocturnalFinance.oracleAddress()).getCurrentPrice(_address);
            currentPrice = OracleInterface(nocturnalFinance.oracleAddress()).getPriceReciprocal(currentPrice);
        }
        
        if (above == true) {
            require(currentPrice >= limitPrice, "limit not met");
        } else if (above == false) {
            require(currentPrice <= limitPrice, "limit not met");
        }
      
        uint256 fromTokenBalance = OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapFromTokenBalance(_address);
        uint256 settlementGratuity = OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapSettlementGratuity(_address);
        address orderCreatorAddress = OrderInterface(nocturnalFinance.orderAddress()).ownerOf(OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapOrderID(_address));
        uint256 sFTVIE = OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapFromTokenValueInETH(_address);
        
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
            OrderTransferInterface(nocturnalFinance.orderTransferAddress()).fromWETHSettle(_address, fromToken0);        
        // 3)  If toToken is WETH, perform the swap and then deduct gratuity from WETH and send to settler
        } else {
            OrderTransferInterface(nocturnalFinance.orderTransferAddress()).toWETHSettle(_address, fromToken0);
        }
        // update Order toTokenBalance attribute for order closure
        OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).setOrderToTokenBalance(_address, fromTokenBalance.sub(gratuity));
        // update Order fromTokenBalance attribute for order closure
        OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).setOrderFromTokenBalance(_address, 0);
        // set swap settle flag to true
        OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).setOrderSettledFlag(_address, true);            
        // 4)  Distribute the NOCT rewards to the settler and the creator 
        distributeNOCTRewards(sFTVIE, orderCreatorAddress);
        // increment platform volume tracker counter
        platformVolume.add(sFTVIE);
        // 6) emit events
        emit orderSettled(OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapOrderID(_address), _address, settlementGratuity);
        emit platformVolumeUpdate(platformVolume);
    }

    function distributeNOCTRewards(uint256 sFTVIE, address orderCreatorAddress) internal {
        
        uint256 totalRewards = RewardsInterface(nocturnalFinance.rewardsAddress()).calcRewards(sFTVIE);
        
        // distribute treasury rewards
        uint256 treasuryRewards = totalRewards.mul(nocturnalFinance.treasuryFactor()).div(bPDivisor);
        RewardsInterface(nocturnalFinance.rewardsAddress()).unclaimedRewards(nocturnalFinance.treasuryAddress()).add(treasuryRewards);
        RewardsInterface(nocturnalFinance.rewardsAddress()).totalRewards().add(treasuryRewards);
        
        totalRewards = totalRewards.sub(treasuryRewards);
    
        // distribute creator rewards
        uint256 creatorRewards = totalRewards.mul(nocturnalFinance.rewardsFactor()).div(bPDivisor);
        RewardsInterface(nocturnalFinance.rewardsAddress()).unclaimedRewards(orderCreatorAddress).add(creatorRewards);
        RewardsInterface(nocturnalFinance.rewardsAddress()).totalRewards().add(creatorRewards);
        
        // distribute settler rewards
        uint256 settlerRewards = totalRewards.sub(creatorRewards);
        RewardsInterface(nocturnalFinance.rewardsAddress()).unclaimedRewards(msg.sender).add(settlerRewards);
        RewardsInterface(nocturnalFinance.rewardsAddress()).totalRewards().add(settlerRewards);
        
        
    }
}
