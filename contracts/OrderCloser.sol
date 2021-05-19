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
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {OrderInterface} from "./Interfaces/OrderInterface.sol";
import {OrderFactoryInterface} from "./Interfaces/OrderFactoryInterface.sol";

contract OrderCloser {
    
    // may include all attributes in events
    // someone may want to analyze trade data in future
    event orderClosed(uint256 _orderID, address _orderAddress);
    
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance) {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
    }
    
    function closeLimitOrder(address _address) external {
        require(msg.sender == nocturnalFinance.orderFactoryAddress(), "caller is not order factory");
        if (OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapSettledFlag(_address) == true) {
            // transfer fromTokenBalance from order to msg.sender address
            OrderInterface(nocturnalFinance.orderAddress()).closeOrder(OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapOrderID(_address), OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapToTokenAddress(_address), msg.sender, OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapToTokenBalance(_address));
            // burn order
            OrderInterface(nocturnalFinance.orderAddress()).burn(OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapOrderID(_address));  
        } else {
            // transfer fromTokenBalance from order to msg.sender address
            require(IERC20(OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapFromTokenAddress(_address)).transferFrom(_address, msg.sender, OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapFromTokenBalance(_address)), "order to creator balance transfer failed");
            // burn order
            OrderInterface(nocturnalFinance.orderAddress()).burn(OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapOrderID(_address));  
        }
        // emit events
        emit orderClosed(OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapOrderID(_address), _address);
    }
}
