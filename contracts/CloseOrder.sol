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

contract CloseOrder is CloseOrderInterface {
    using SafeMath for uint256;

    event orderClosed(uint256 _orderID);
    address WETH;
    
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance, address _WETH) {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
        WETH = _WETH;
    }
    
    function closeOrder(uint256 _orderID, CloseParams calldata params) external override {
        require(msg.sender == nocturnalFinance._contract(1), "caller is not order factory");
        require(params.closedFlag == false);
        address orderOwnerAddress = OrderInterface(nocturnalFinance._contract(8)).ownerOf(_orderID);
        
        if (params.settledFlag == true) {
            // transfer tokenBalance to owner address
            OrderInterface(params.orderAddress).orderTransfer(params.toTokenAddress, orderOwnerAddress, (params.tokenBalance));
            // burn order
            OrderInterface(nocturnalFinance._contract(8)).burn(_orderID);  
        } else if (params.depositedFlag == true) {
            // transfer fromTokenBalance from order to order owner address
            OrderInterface(params.orderAddress).orderTransfer(params.fromTokenAddress, orderOwnerAddress, params.tokenBalance);
            // burn order
            OrderInterface(nocturnalFinance._contract(8)).burn(_orderID);
        } else {
            // burn order
            OrderInterface(nocturnalFinance._contract(8)).burn(_orderID);  
        }
        // set tokenBalance to 0 and set order closed flag
        CreateOrderInterface(nocturnalFinance._contract(1)).setAttributes(_orderID, 0);  
        // emit events
        emit orderClosed(_orderID);
    }
}
