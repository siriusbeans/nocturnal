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

contract SettleOrderTransfer is SettleOrderTransferInterface {
    using SafeMath for uint256;
    
    //uint256 internal constant bPDivisor = 10000;  // 100th of a bip
    
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance) {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
    }
    
    function fromWETHSettle(uint256 _orderID, SettleTransferParams calldata params) external override {
        require(msg.sender == nocturnalFinance._contract(3), "not SettleOrder contract");
        uint256 gratuity = (params.tokenBalance).mul(params.settlementGratuity).div(10000);

        OrderInterface(params.orderAddress).orderTransfer(params.fromTokenAddress, msg.sender, gratuity);        
        if (IUniswapV3Pool(params.poolAddress).token0() == params.fromTokenAddress) {
            OrderInterface(params.orderAddress).getExactInputSingle(
                IUniswapV3Pool(params.poolAddress).token0(),
                IUniswapV3Pool(params.poolAddress).token1(), 
                IUniswapV3Pool(params.poolAddress).fee(), 
                params.orderAddress, 
                (params.tokenBalance).sub(gratuity));
        } else {
            OrderInterface(params.orderAddress).getExactInputSingle(
                IUniswapV3Pool(params.poolAddress).token1(),
                IUniswapV3Pool(params.poolAddress).token0(), 
                IUniswapV3Pool(params.poolAddress).fee(), 
                params.orderAddress, 
                (params.tokenBalance).sub(gratuity));  
        }
        // update Order toTokenBalance attribute for order closure
        CreateOrderInterface(nocturnalFinance._contract(1)).setTokenBalance(_orderID, params.tokenBalance);
    }

    function toWETHSettle(uint256 _orderID, SettleTransferParams calldata params) external override {
        require(msg.sender == nocturnalFinance._contract(3), "not SettleOrder contract");
        uint256 gratuity = (params.tokenBalance).mul(params.settlementGratuity).div(10000);
        
        if (IUniswapV3Pool(params.poolAddress).token0() == params.fromTokenAddress) {
            OrderInterface(params.orderAddress).getExactInputSingle(
                IUniswapV3Pool(params.poolAddress).token0(),
                IUniswapV3Pool(params.poolAddress).token1(), 
                IUniswapV3Pool(params.poolAddress).fee(), 
                msg.sender, 
                gratuity);
            OrderInterface(params.orderAddress).getExactInputSingle(                 
                IUniswapV3Pool(params.poolAddress).token0(),
                IUniswapV3Pool(params.poolAddress).token1(), 
                IUniswapV3Pool(params.poolAddress).fee(), 
                params.orderAddress, 
                (params.tokenBalance).sub(gratuity));
        } else {
            OrderInterface(params.orderAddress).getExactInputSingle(
                IUniswapV3Pool(params.poolAddress).token1(),
                IUniswapV3Pool(params.poolAddress).token0(), 
                IUniswapV3Pool(params.poolAddress).fee(), 
                msg.sender, 
                gratuity);  
            OrderInterface(params.orderAddress).getExactInputSingle(
                IUniswapV3Pool(params.poolAddress).token1(),
                IUniswapV3Pool(params.poolAddress).token0(), 
                IUniswapV3Pool(params.poolAddress).fee(), 
                params.orderAddress, 
                (params.tokenBalance).sub(gratuity));
        }
        // update Order toTokenBalance attribute for order closure
        CreateOrderInterface(nocturnalFinance._contract(1)).setTokenBalance(_orderID, params.tokenBalance);
    }
}
