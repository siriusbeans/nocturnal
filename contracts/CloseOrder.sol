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
import "./Interfaces/CloseOrderInterface.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {OrderInterface} from "./Interfaces/OrderInterface.sol";
import {CreateOrderInterface} from "./Interfaces/CreateOrderInterface.sol";
import {OrderSlippageInterface} from "./Interfaces/OrderSlippageInterface.sol";

contract CloseOrder is CloseOrderInterface {
    using SafeMath for uint256;

    //uint256 internal constant bPDivisor = 10000;  // 100th of a bip
    event orderClosed(uint256 _orderID);
    address WETH;
    
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance, address _WETH) {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
        WETH = _WETH;
    }
    
    function closeOrder(uint256 _orderID, CloseParams calldata params) external override {
        require(msg.sender == nocturnalFinance._contract(1), "caller is not order factory");
        address orderOwnerAddress = OrderInterface(params.orderAddress).ownerOf(_orderID);
        
        if (params.settledFlag == true) {
            // deduct dfee from toTokenBalance and send staking.sol before transfering toTokenBalance to owner address
            uint256 dFee = (params.tokenBalance).mul(nocturnalFinance.platformRate()).div(10000);
            if (params.toTokenAddress == WETH) {
                // if toTokenAddress == WETH, transferFrom order.sol dFee to staking.sol
                OrderInterface(params.orderAddress).orderTransfer(params.toTokenAddress, nocturnalFinance._contract(0), dFee);
            } else {
                // else swap dFee to WETH and send it to staking.sol
                uint256 minOut = OrderSlippageInterface(nocturnalFinance._contract(13)).minOut(params.poolAddress, params.fromTokenAddress, dFee, params.slippage);
                if (IUniswapV3Pool(params.poolAddress).token0() == params.fromTokenAddress) {
                    OrderInterface(params.orderAddress).getExactInputSingle(
                        IUniswapV3Pool(params.poolAddress).token0(),
                        IUniswapV3Pool(params.poolAddress).token1(), 
                        IUniswapV3Pool(params.poolAddress).fee(), 
                        nocturnalFinance._contract(0), 
                        minOut,
                        dFee);
                } else {
                    OrderInterface(params.orderAddress).getExactInputSingle(
                        IUniswapV3Pool(params.poolAddress).token1(),
                        IUniswapV3Pool(params.poolAddress).token0(), 
                        IUniswapV3Pool(params.poolAddress).fee(), 
                        nocturnalFinance._contract(0), 
                        minOut,
                        dFee);
                }
            }
            // transfer remaining toTokenBalance from order to order owner address
            OrderInterface(params.orderAddress).orderTransfer(params.toTokenAddress, orderOwnerAddress, (params.tokenBalance).sub(dFee));
            // burn order
            OrderInterface(params.orderAddress).burn(_orderID);  
        } else if (params.depositedFlag == true) {
            // transfer fromTokenBalance from order to order owner address
            OrderInterface(params.orderAddress).orderTransfer(params.fromTokenAddress, orderOwnerAddress, params.tokenBalance);
            // burn order
            OrderInterface(params.orderAddress).burn(_orderID);  
        } else {
            // burn order
            OrderInterface(params.orderAddress).burn(_orderID);  
        }
        // emit events
        emit orderClosed(_orderID);
    }
}
