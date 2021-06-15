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
pragma abicoder v2;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {IERC20} from "../../shared/interfaces/IERC20.sol";
import {OrderAttributes, AppStorage, LibAppStorage} from "../libraries/LibAppStorage.sol";
import {OrderInterface} from "../Interfaces/OrderInterface.sol";
import {NoctStakingInterface} from "../Interfaces/NoctStakingInterface.sol";
import {DistributeRewardsInterface} from "../Interfaces/DistributeRewardsInterface.sol";
import {OracleInterface} from "../Interfaces/OracleInterface.sol";


contract SettleOrderFacet {
    AppStorage internal s;

    using SafeMath for uint256;
    
    uint256 public platformVolume;
    address WETH; 

    event orderSettled(uint256 _orderID);
    event platformVolumeUpdate(uint256 _volume);

    constructor(address _WETH) {
        WETH = _WETH;
    }
    
    function settleOrder(uint256 _orderID) external {
        // AppStorage 
        OrderAttributes storage orderAttributes = s._attributes[_orderID];
        
        require(orderAttributes.depositedFlag == true, "order not deposited");
        require(orderAttributes.settledFlag == false, "order settled");
        
        uint256 currentPrice;
        uint256 noctVol;
        
        // the limit price value returned by the front end is denominated by ETH
        // so choose current pool price with WETH in denominator
        if (IUniswapV3Pool(orderAttributes.poolAddress).token0() == WETH) {
            currentPrice = OracleInterface(s.oracleFacetAddress).getCurrentPriceReciprocal(orderAttributes.poolAddress);
        } else {
            currentPrice = OracleInterface(s.oracleFacetAddress).getCurrentPrice(orderAttributes.poolAddress);
        }
        
        if (orderAttributes.limitType == true) {
            require(currentPrice >= orderAttributes.limitPrice, "limit not met");
        } else {
            require(currentPrice <= orderAttributes.limitPrice, "limit not met");
        }
        
        // perform swap + send gratuity + send fee
        if (orderAttributes.fromTokenAddress == WETH) {
            noctVol = fromWETHSettle(_orderID, msg.sender);        
        } else {
            noctVol = toWETHSettle(_orderID, msg.sender);
        }
                   
        // distribute the NOCT rewards to the settler and the creator 

        DistributeRewardsInterface(s.distributeRewardsFacetAddress).distributeNOCT(_orderID, noctVol, msg.sender);
        
        // increment platform volume tracker counter
        platformVolume.add(noctVol);
        
        // emit events
        emit orderSettled(_orderID);
        emit platformVolumeUpdate(platformVolume);
    }
    
    function fromWETHSettle(uint256 _orderID, address _settler) internal returns (uint256) {
        // AppStorage 
        OrderAttributes storage orderAttributes = s._attributes[orderCounter.current()];
        
        uint256 amountOut;
        // calculate fee prior to swap from WETH
        uint256 dFee = (orderAttributes.tokenBalance).mul(nocturnalFinance.platformRate()).div(10000);
        OrderInterface(orderAttributes[_orderID].orderAddress).orderTransfer(orderAttributes.fromTokenAddress, _settler, orderAttributes.settlementGratuity); 
        //OrderInterface(orderAttributes.orderAddress).orderPayment(_settler, orderAttributes.settlementGratuity); 
        OrderInterface(orderAttributes[_orderID].orderAddress).orderTransfer(orderAttributes.fromTokenAddress, s.noctStakingAddress, dFee);
        NoctStakingInterface(s.noctStakingAddress).updateTRG(dFee);
        
        uint256 tokenBalance = IERC20(orderAttributes.fromTokenAddress).balanceOf(orderAttributes.orderFacetAddress); 
        if (IUniswapV3Pool(orderAttributes.poolAddress).token0() == orderAttributes.fromTokenAddress) {
            amountOut = OrderInterface(orderAttributes[_orderID].orderAddress).getExactInputSingle(
                IUniswapV3Pool(orderAttributes.poolAddress).token0(),
                IUniswapV3Pool(orderAttributes.poolAddress).token1(), 
                IUniswapV3Pool(orderAttributes.poolAddress).fee(), 
                orderAttributes.orderFacetAddress, 
                orderAttributes.amountOutMin,
                tokenBalance);
        } else {
            amountOut = OrderInterface(orderAttributes[_orderID].orderAddress).getExactInputSingle(                   
                IUniswapV3Pool(orderAttributes.poolAddress).token1(),
                IUniswapV3Pool(orderAttributes.poolAddress).token0(), 
                IUniswapV3Pool(orderAttributes.poolAddress).fee(), 
                orderAttributes.orderFacetAddress, 
                orderAttributes.amountOutMin,
                tokenBalance);  
        }
        // set Order toTokenBalance and settledFlag attributes
        amountOut = IERC20(orderAttributes.toTokenAddress).balanceOf(orderAttributes.orderFacetAddress);
        orderAttributes.tokenBalance = amountOut; 
        orderAttributes.settledFlag = true;
        return (orderAttributes.tokenBalance); // return amount of WETH involved in order swap (volume tracking)
    }

    function toWETHSettle(uint256 _orderID, address _settler) internal returns (uint256) {
       // AppStorage 
        OrderAttributes storage orderAttributes = s._attributes[orderCounter.current()];
        
        uint256 amountOut;
        if (IUniswapV3Pool(orderAttributes.poolAddress).token0() == orderAttributes.fromTokenAddress) {
           amountOut = OrderInterface(orderAttributes[_orderID].orderAddress).getExactInputSingle(                 
                IUniswapV3Pool(orderAttributes.poolAddress).token0(),
                IUniswapV3Pool(orderAttributes.poolAddress).token1(), 
                IUniswapV3Pool(orderAttributes.poolAddress).fee(), 
                orderAttributes.orderFacetAddress, 
                orderAttributes.amountOutMin,
                orderAttributes.tokenBalance);
        } else { 
           amountOut = OrderInterface(orderAttributes[_orderID].orderAddress).getExactInputSingle(     
                IUniswapV3Pool(orderAttributes.poolAddress).token1(),
                IUniswapV3Pool(orderAttributes.poolAddress).token0(), 
                IUniswapV3Pool(orderAttributes.poolAddress).fee(), 
                orderAttributes.orderFacetAddress, 
                orderAttributes.amountOutMin,
                orderAttributes.tokenBalance);
        }
        // calculate fee after swap to WETH 
        amountOut = IERC20(orderAttributes.toTokenAddress).balanceOf(orderAttributes.orderFacetAddress);
        uint256 dFee = (amountOut).mul(nocturnalFinance.platformRate()).div(10000);
        OrderInterface(orderAttributes[_orderID].orderAddress).orderTransfer(orderAttributes.toTokenAddress, _settler, orderAttributes.settlementGratuity); 
        //OrderInterface(orderAttributes.orderAddress).orderPayment(_settler, orderAttributes.settlementGratuity); 
        OrderInterface(orderAttributes[_orderID].orderAddress).orderTransfer(orderAttributes.toTokenAddress, s.noctStakingAddress, dFee);
        NoctStakingInterface(s.noctStakingAddress).updateTRG(dFee);

        
        // set Order toTokenBalance and settledFlag attributes
        amountOut = IERC20(orderAttributes.toTokenAddress).balanceOf(orderAttributes.orderFacetAddress);
        orderAttributes.tokenBalance = amountOut; 
        orderAttributes.settledFlag = true;
        return (amountOut); // return amount of WETH involved in order swap (volume tracking)
    }
}
