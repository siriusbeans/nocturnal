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

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "./Interfaces/SettleOrderTransferInterface.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {OrderInterface} from "./Interfaces/OrderInterface.sol";
import {SettleOrderInterface} from "./Interfaces/SettleOrderInterface.sol";
import {CreateOrderInterface} from "./Interfaces/CreateOrderInterface.sol";
import {NoctStakingInterface} from "./Interfaces/NoctStakingInterface.sol";

contract SettleOrderTransfer is SettleOrderTransferInterface {
    using SafeMath for uint256;
    
    //uint256 internal constant bPDivisor = 10000;  // 100th of a bip
    
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance) {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
    }
    
    function fromWETHSettle(uint256 _orderID, SettleTransferParams calldata params, address _settler) external override returns (uint256) {
        require(msg.sender == nocturnalFinance._contract(3), "not SettleOrder contract");
        uint256 amountOut;
        // calculate fee prior to swap from WETH
        uint256 dFee = (params.tokenBalance).mul(nocturnalFinance.platformRate()).div(10000);
        OrderInterface(params.orderAddress).orderTransfer(params.fromTokenAddress, _settler, params.settlementGratuity); 
        //OrderInterface(params.orderAddress).orderPayment(_settler, params.settlementGratuity); 
        OrderInterface(params.orderAddress).orderTransfer(params.fromTokenAddress, nocturnalFinance._contract(0), dFee);
        NoctStakingInterface(nocturnalFinance._contract(0)).updateTRG(dFee);
        
        uint256 tokenBalance = IERC20(params.fromTokenAddress).balanceOf(params.orderAddress); 
        if (IUniswapV3Pool(params.poolAddress).token0() == params.fromTokenAddress) {
            amountOut = OrderInterface(params.orderAddress).getExactInputSingle(
                IUniswapV3Pool(params.poolAddress).token0(),
                IUniswapV3Pool(params.poolAddress).token1(), 
                IUniswapV3Pool(params.poolAddress).fee(), 
                params.orderAddress, 
                params.amountOutMin,
                tokenBalance);
        } else {
            amountOut = OrderInterface(params.orderAddress).getExactInputSingle(
                IUniswapV3Pool(params.poolAddress).token1(),
                IUniswapV3Pool(params.poolAddress).token0(), 
                IUniswapV3Pool(params.poolAddress).fee(), 
                params.orderAddress, 
                params.amountOutMin,
                tokenBalance);  
        }
        // set Order toTokenBalance and settledFlag attributes
        amountOut = IERC20(params.toTokenAddress).balanceOf(params.orderAddress);
        CreateOrderInterface(nocturnalFinance._contract(1)).setAttributes(_orderID, amountOut); 
        return (params.tokenBalance); // return amount of WETH involved in order swap (volume tracking)
    }

    function toWETHSettle(uint256 _orderID, SettleTransferParams calldata params, address _settler) external override returns (uint256) {
        require(msg.sender == nocturnalFinance._contract(3), "not SettleOrder contract");
        uint256 amountOut;
        if (IUniswapV3Pool(params.poolAddress).token0() == params.fromTokenAddress) {
           amountOut = OrderInterface(params.orderAddress).getExactInputSingle(                 
                IUniswapV3Pool(params.poolAddress).token0(),
                IUniswapV3Pool(params.poolAddress).token1(), 
                IUniswapV3Pool(params.poolAddress).fee(), 
                params.orderAddress, 
                params.amountOutMin,
                params.tokenBalance);
        } else { 
           amountOut = OrderInterface(params.orderAddress).getExactInputSingle(     
                IUniswapV3Pool(params.poolAddress).token1(),
                IUniswapV3Pool(params.poolAddress).token0(), 
                IUniswapV3Pool(params.poolAddress).fee(), 
                params.orderAddress, 
                params.amountOutMin,
                params.tokenBalance);
        }
        // calculate fee after swap to WETH 
        amountOut = IERC20(params.toTokenAddress).balanceOf(params.orderAddress);
        uint256 dFee = (amountOut).mul(nocturnalFinance.platformRate()).div(10000);
        OrderInterface(params.orderAddress).orderTransfer(params.toTokenAddress, _settler, params.settlementGratuity); 
        //OrderInterface(params.orderAddress).orderPayment(_settler, params.settlementGratuity); 
        OrderInterface(params.orderAddress).orderTransfer(params.toTokenAddress, nocturnalFinance._contract(0), dFee);
        NoctStakingInterface(nocturnalFinance._contract(0)).updateTRG(dFee);

        
        // set Order toTokenBalance and settledFlag attributes
        amountOut = IERC20(params.toTokenAddress).balanceOf(params.orderAddress);
        CreateOrderInterface(nocturnalFinance._contract(1)).setAttributes(_orderID, amountOut);  
        return (amountOut); // return amount of WETH involved in order swap (volume tracking)
    }
}
