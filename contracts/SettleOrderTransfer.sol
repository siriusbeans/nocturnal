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
import {CreateOrderInterface} from "./Interfaces/CreateOrderInterface.sol";

contract SettleOrderTransfer {
    using SafeMath for uint256;
    
    uint256 internal constant bPDivisor = 10000;  // 100th of a bip
    
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance) {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
    }
    
    function fromWETHSettle(uint256 _orderID) external {
        require(msg.sender == nocturnalFinance.settleOrderAddress(), "not SettleOrder contract");
        (address orderAddress,address poolAddress,address fromTokenAddress,,uint256 tokenBalance,,,,,uint256 gratuity,,) = CreateOrderInterface(nocturnalFinance.createOrderAddress()).orderAttributes(_orderID);
        gratuity = tokenBalance.mul(gratuity).div(bPDivisor);

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
        // update Order toTokenBalance attribute for order closure
        CreateOrderInterface(nocturnalFinance.createOrderAddress()).setTokenBalance(_orderID, tokenBalance);
    }

    function toWETHSettle(uint256 _orderID) external {
        require(msg.sender == nocturnalFinance.settleOrderAddress(), "not SettleOrder contract");
        (address orderAddress,address poolAddress,address fromTokenAddress,,uint256 tokenBalance,,,,,uint256 gratuity,,) = CreateOrderInterface(nocturnalFinance.createOrderAddress()).orderAttributes(_orderID);
        gratuity = tokenBalance.mul(gratuity).div(bPDivisor);
        
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
        // update Order toTokenBalance attribute for order closure
        CreateOrderInterface(nocturnalFinance.createOrderAddress()).setTokenBalance(_orderID, tokenBalance);
    }
}
