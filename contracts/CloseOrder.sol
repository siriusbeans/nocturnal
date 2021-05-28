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
import {OrderManagerInterface} from "./Interfaces/OrderManagerInterface.sol";

contract CloseOrder {
    using SafeMath for uint256;

    uint256 internal constant bPDivisor = 10000;  // 100th of a bip
    event orderClosed(uint256 _orderID);
    address WETH;
    
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance, address _WETH) {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
        WETH = _WETH;
    }
    
    function closeOrder(uint256 _orderID) external {
        require(msg.sender == nocturnalFinance.orderManagerAddress(), "caller is not order factory");
        (,,,,,,,,,,,bool settledFlag) = OrderManagerInterface(nocturnalFinance.orderManagerAddress()).getOrderAttributes(_orderID);
        (,,,address toTokenAddress,,,,,,,,) = OrderManagerInterface(nocturnalFinance.orderManagerAddress()).getOrderAttributes(_orderID);
        (,,,,,uint256 toTokenBalance,,,,,,) = OrderManagerInterface(nocturnalFinance.orderManagerAddress()).getOrderAttributes(_orderID);
        (,,address fromTokenAddress,,,,,,,,,) = OrderManagerInterface(nocturnalFinance.orderManagerAddress()).getOrderAttributes(_orderID);
        (,,,,uint256 fromTokenBalance,,,,,,,) = OrderManagerInterface(nocturnalFinance.orderManagerAddress()).getOrderAttributes(_orderID);
        //(,,,,,,,,,uint256 slippage,,) = OrderManagerInterface(nocturnalFinance.orderManagerAddress()).getOrderAttributes(_orderID);
        (,address poolAddress,,,,,,,,,,) = OrderManagerInterface(nocturnalFinance.orderManagerAddress()).getOrderAttributes(_orderID);
        (address orderAddress,,,,,,,,,,,) = OrderManagerInterface(nocturnalFinance.orderManagerAddress()).getOrderAttributes(_orderID);
        address orderOwnerAddress = OrderInterface(orderAddress).ownerOf(_orderID);
        
        uint256 dFee = toTokenBalance.mul(nocturnalFinance.platformRate()).div(bPDivisor);
        
        if (settledFlag == true) {
            // deduct dfee from toTokenBalance and send staking.sol before transfering toTokenBalance to owner address
            if (toTokenAddress == WETH) {
                // if toTokenAddress == WETH, transferFrom order.sol dFee to staking.sol
                OrderInterface(orderAddress).orderTransfer(toTokenAddress, nocturnalFinance.sNoctAddress(), dFee);
            } else {
                // else swap dFee to WETH and send it to staking.sol
                if (IUniswapV3Pool(poolAddress).token0() == fromTokenAddress) {
                    OrderInterface(orderAddress).getExactInputSingle(
                        IUniswapV3Pool(poolAddress).token0(),
                        IUniswapV3Pool(poolAddress).token1(), 
                        IUniswapV3Pool(poolAddress).fee(), 
                        nocturnalFinance.sNoctAddress(), 
                        dFee);
                } else {
                    OrderInterface(orderAddress).getExactInputSingle(
                        IUniswapV3Pool(poolAddress).token1(),
                        IUniswapV3Pool(poolAddress).token0(), 
                        IUniswapV3Pool(poolAddress).fee(), 
                        nocturnalFinance.sNoctAddress(), 
                        dFee);
                }
            }
            // transfer remaining toTokenBalance from order to order owner address
            OrderInterface(orderAddress).orderTransfer(toTokenAddress, orderOwnerAddress, toTokenBalance.sub(dFee));
            // burn order
            OrderInterface(orderAddress).burn(_orderID);  
        } else {
            // transfer fromTokenBalance from order to order owner address
            OrderInterface(orderAddress).orderTransfer(fromTokenAddress, orderOwnerAddress, fromTokenBalance);
            // burn order
            OrderInterface(orderAddress).burn(_orderID);  
        }
        // emit events
        emit orderClosed(_orderID);
    }
}