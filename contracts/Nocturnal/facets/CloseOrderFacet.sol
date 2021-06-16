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

import {IERC20} from "../../shared/interfaces/IERC20.sol";
import {OrderAttributes, AppStorage, LibAppStorage} from "../libraries/LibAppStorage.sol";
import {OrderInterface} from "../Interfaces/OrderInterface.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";

contract CloseOrderFacet {
    AppStorage internal s;
    
    event orderClosed(uint256 _orderID);
    
    constructor() {
    }
    
    function closeOrder(uint256 _orderID) external {
        // AppStorage 
        OrderAttributes storage orderAttributes = s._attributes[_orderID];
        
        require(LibMeta.msgSender() == OrderInterface(s.orderAddress).ownerOf(_orderID), "not order owner");
        require(orderAttributes.closedFlag == false);
        
        address orderOwnerAddress = OrderInterface(s.orderAddress).ownerOf(_orderID);
        
        if (orderAttributes.settledFlag == true) {
            // transfer tokenBalance to owner address
            OrderInterface(orderAttributes.orderAddress).orderTransfer(orderAttributes.toTokenAddress, orderOwnerAddress, (orderAttributes.tokenBalance));
            // burn order
            OrderInterface(orderAttributes.orderAddress).burn(_orderID);
        } else if (orderAttributes.depositedFlag == true) {
            // transfer fromTokenBalance from order to order owner address
            OrderInterface(orderAttributes.orderAddress).orderTransfer(orderAttributes.fromTokenAddress, orderOwnerAddress, orderAttributes.tokenBalance);
            // burn order
            OrderInterface(orderAttributes.orderAddress).burn(_orderID);
        } else {
            // burn order
            OrderInterface(orderAttributes.orderAddress).burn(_orderID);  
        }
        // set tokenBalance to 0 and set order closed flag
        orderAttributes.tokenBalance = 0;
        orderAttributes.closedFlag = true;
        // emit events
        emit orderClosed(_orderID);
    }
}
