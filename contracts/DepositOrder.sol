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
import "./Interfaces/DepositOrderInterface.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {OrderInterface} from "./Interfaces/OrderInterface.sol";
import {CreateOrderInterface} from "./Interfaces/CreateOrderInterface.sol";
import {OracleInterface} from "./Interfaces/OracleInterface.sol";

contract DepositOrder is DepositOrderInterface {
    using SafeMath for uint256;

    address WETH;

    event orderDeposited(uint256 _orderID);
    
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance, address _WETH) {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
        WETH = _WETH;
    }

    function depositOrder(uint256 _orderID, DepositParams calldata params) public override {
        require(msg.sender == nocturnalFinance._contract(1));
        require(params.depositedFlag == false, "deposit filled");
        address orderOwnerAddress = OrderInterface(params.orderAddress).ownerOf(_orderID);
       
        // transfer fromTokenBalance to order
        // requires orderOwner to approve DepositOrder.sol trasnferFrom allowance 
        require(IERC20(params.fromTokenAddress).transferFrom(orderOwnerAddress, params.orderAddress, params.tokenBalance), "owner to order balance transfer failed");
       
        // set fromTokenBalance in ETH attribute
        if (params.fromTokenAddress == WETH) {
            // set fromTokenBalanceValueInETH and depositedFlag
                CreateOrderInterface(nocturnalFinance._contract(1)).setAttributes(_orderID, params.tokenBalance);  
                       
        } else {
            // set fromTokenBalance value in ETH order attribute
            if (IUniswapV3Pool(params.poolAddress).token0() == params.fromTokenAddress) {
                // use reciprocal of current price
                CreateOrderInterface(nocturnalFinance._contract(1)).setAttributes(_orderID, (params.tokenBalance).mul(OracleInterface(nocturnalFinance._contract(7)).getCurrentPriceReciprocal(params.poolAddress)));  
            } else {           
                // use current price    
                CreateOrderInterface(nocturnalFinance._contract(1)).setAttributes(_orderID, (params.tokenBalance).mul(OracleInterface(nocturnalFinance._contract(7)).getCurrentPrice(params.poolAddress)));  
            }
        }
        // emit events                                                
        emit orderDeposited(_orderID);
    }
}
