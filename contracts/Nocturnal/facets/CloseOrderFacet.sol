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
pragma abicoder v2;

import {IERC20} from "../shared/interfaces/IERC20.sol";
import {OrderAttributes, AppStorage, LibAppStorage} from "./libraries/LibAppStorage.sol";
//import {OrderInterface} from "./Interfaces/OrderInterface.sol";
import "../Order.sol"

contract CloseOrderFacet is Order {
    AppStorage internal s;
    
    event orderClosed(uint256 _orderID);
    
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor() {
    }
    
    function closeOrder(uint256 _orderID) external {
        // AppStorage 
        OrderAttributes storage orderAttributes = s._attributes[orderCounter.current()];
    
        require(msg.sender == ownerOf(_orderID));
        require(orderAttributes.closedFlag == false);
        
        address orderOwnerAddress = ownerOf(_orderID);
        
        if (orderAttributes[_orderID].settledFlag == true) {
            // transfer tokenBalance to owner address
            orderTransfer(orderAttributes[_orderID].toTokenAddress, orderOwnerAddress, (orderAttributes[_orderID].tokenBalance));
            // burn order
            burn(_orderID);  
        } else if (orderAttributes[_orderID].depositedFlag == true) {
            // transfer fromTokenBalance from order to order owner address
            orderTransfer(orderAttributes[_orderID].fromTokenAddress, orderOwnerAddress, orderAttributes[_orderID].tokenBalance);
            // burn order
            burn(_orderID);
        } else {
            // burn order
            burn(_orderID);  
        }
        // set tokenBalance to 0 and set order closed flag
        orderAttributes[_orderID].tokenBalance = 0;
        orderAttributes[_orderID].closedFlag = true;
        // emit events
        emit orderClosed(_orderID);
    }
}
