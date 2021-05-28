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
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {OrderInterface} from "./Interfaces/OrderInterface.sol";
import {SettleOrderInterface} from "./Interfaces/SettleOrderInterface.sol";
import {OrderManagerInterface} from "./Interfaces/OrderManagerInterface.sol";

contract SettleOrderTransfer {
    using SafeMath for uint256;
    
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance) {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
    }
    
    function fromWETHSettle(uint256 _orderID) external {
        require(msg.sender == nocturnalFinance.settleOrderAddress(), "not SettleOrder contract");
        (,,address fromTokenAddress,,,,,,,,,) = OrderManagerInterface(nocturnalFinance.orderManagerAddress()).getOrderAttributes(_orderID);
        (,,,,,,,,,uint256 gratuity,,) = OrderManagerInterface(nocturnalFinance.orderManagerAddress()).getOrderAttributes(_orderID);
        (,address poolAddress,,,,,,,,,,) = OrderManagerInterface(nocturnalFinance.orderManagerAddress()).getOrderAttributes(_orderID);
        //(,,,,,,,,uint256 slippage,,,) = OrderManagerInterface(nocturnalFinance.orderManagerAddress()).getOrderAttributes(_orderID);
        (,,,,uint256 tokenBalance,,,,,,,) = OrderManagerInterface(nocturnalFinance.orderManagerAddress()).getOrderAttributes(_orderID);
        (address orderAddress,,,,,,,,,,,) = OrderManagerInterface(nocturnalFinance.orderManagerAddress()).getOrderAttributes(_orderID);
        
        OrderInterface(orderAddress).orderTransfer(fromTokenAddress, msg.sender, gratuity);        
        if (IUniswapV3Pool(poolAddress).token0() == fromTokenAddress) {
            OrderInterface(orderAddress).getExactInputSingle(
                IUniswapV3Pool(poolAddress).token0(),
                IUniswapV3Pool(poolAddress).token1(), 
                IUniswapV3Pool(poolAddress).fee(), 
                orderAddress, 
                tokenBalance.sub(gratuity));
        } else {
            OrderInterface(orderAddress).getExactInputSingle(
                IUniswapV3Pool(poolAddress).token1(),
                IUniswapV3Pool(poolAddress).token0(), 
                IUniswapV3Pool(poolAddress).fee(), 
                orderAddress, 
                tokenBalance.sub(gratuity));  
        }
    }

    function toWETHSettle(uint256 _orderID) external {
        require(msg.sender == nocturnalFinance.settleOrderAddress(), "not SettleOrder contract");
        (,,address fromTokenAddress,,,,,,,,,) = OrderManagerInterface(nocturnalFinance.orderManagerAddress()).getOrderAttributes(_orderID);
        (,,,,,,,,,uint256 gratuity,,) = OrderManagerInterface(nocturnalFinance.orderManagerAddress()).getOrderAttributes(_orderID);
        (,address poolAddress,,,,,,,,,,) = OrderManagerInterface(nocturnalFinance.orderManagerAddress()).getOrderAttributes(_orderID);
        //(,,,,,,,,uint256 slippage,,,) = OrderManagerInterface(nocturnalFinance.orderManagerAddress()).getOrderAttributes(_orderID);
        (,,,,uint256 tokenBalance,,,,,,,) = OrderManagerInterface(nocturnalFinance.orderManagerAddress()).getOrderAttributes(_orderID);
        (address orderAddress,,,,,,,,,,,) = OrderManagerInterface(nocturnalFinance.orderManagerAddress()).getOrderAttributes(_orderID);
        
        if (IUniswapV3Pool(poolAddress).token0() == fromTokenAddress) {
            OrderInterface(orderAddress).getExactInputSingle(
                IUniswapV3Pool(poolAddress).token0(),
                IUniswapV3Pool(poolAddress).token1(), 
                IUniswapV3Pool(poolAddress).fee(), 
                msg.sender, 
                gratuity);
            OrderInterface(orderAddress).getExactInputSingle(
                IUniswapV3Pool(poolAddress).token0(),
                IUniswapV3Pool(poolAddress).token1(), 
                IUniswapV3Pool(poolAddress).fee(), 
                orderAddress, 
                tokenBalance.sub(gratuity));
        } else {
            OrderInterface(orderAddress).getExactInputSingle(
                IUniswapV3Pool(poolAddress).token1(),
                IUniswapV3Pool(poolAddress).token0(), 
                IUniswapV3Pool(poolAddress).fee(), 
                msg.sender, 
                gratuity);  
            OrderInterface(orderAddress).getExactInputSingle(
                IUniswapV3Pool(poolAddress).token1(),
                IUniswapV3Pool(poolAddress).token0(), 
                IUniswapV3Pool(poolAddress).fee(), 
                orderAddress, 
                tokenBalance.sub(gratuity));
        }
    }
}
