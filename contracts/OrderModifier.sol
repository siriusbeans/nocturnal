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

import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {OrderInterface} from "./Interfaces/OrderInterface.sol";
import {OrderFactoryInterface} from "./Interfaces/OrderFactoryInterface.sol";

contract OrderModifier {
    
    // may include all attributes in events
    // someone may want to analyze trade data in future
    event orderModified(uint256 _orderID, address _orderAddress, uint256 _settlementGratuity);
    
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance) {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
    }
    
    function modifyOrderSwapSlippage(address _orderAddress, uint256 _newSwapSlippage) external {
        require(msg.sender == nocturnalFinance.orderFactoryAddress(), "caller is not order factory");
        uint256 orderID = OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapOrderID(_orderAddress);
        require(OrderInterface(nocturnalFinance.orderAddress()).ownerOf(orderID) == msg.sender, "only owner can modify an existing order");
        OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).setOrderSwapSlippage(_orderAddress, _newSwapSlippage);
      
        uint256 settlementGratuity = OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapSettlementGratuity(_orderAddress);
        
        emit orderModified(orderID, _orderAddress, settlementGratuity);      
    }
    
    function modifyOrderSettlementGratuity(address _orderAddress, uint256 _newSettlementGratuity) external {
        require(msg.sender == nocturnalFinance.orderFactoryAddress(), "caller is not order factory");
        uint256 orderID = OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapOrderID(_orderAddress);
        require(OrderInterface(nocturnalFinance.orderAddress()).ownerOf(orderID) == msg.sender, "only owner can modify an existing order");
        OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).setOrderSettlementGratuity(_orderAddress, _newSettlementGratuity);      
        
        emit orderModified(orderID, _orderAddress, _newSettlementGratuity);      
    }
}
