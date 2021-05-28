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
import {OrderManagerInterface} from "./Interfaces/OrderManagerInterface.sol";
import {CreateOrderInterface} from "./Interfaces/CreateOrderInterface.sol";

contract ModifyOrder {
   
    event orderModified(uint256 _orderID);
    
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance) {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
    }
    
    function modifySlippage(uint256 _orderID, uint256 _slippage) external {
        require(msg.sender == nocturnalFinance.orderManagerAddress(), "not order manager");
        CreateOrderInterface(nocturnalFinance.createOrderAddress()).setSlippage(_orderID, _slippage);
        emit orderModified(_orderID);      
    }
    
    function modifySettlementGratuity(uint256 _orderID, uint256 _gratuity) external {
        require(msg.sender == nocturnalFinance.orderManagerAddress(), "not order manager");
        CreateOrderInterface(nocturnalFinance.createOrderAddress()).setSettlementGratuity(_orderID, _gratuity);      
        emit orderModified(_orderID);      
    }
}
