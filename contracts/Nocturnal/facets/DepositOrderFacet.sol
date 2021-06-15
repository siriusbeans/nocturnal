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

contract DepositOrderFacet {
    AppStorage internal s;

    event orderDeposited(uint256 _orderID);
    
    constructor() {
    }

    function depositOrder(uint256 _orderID) external {s
        // AppStorage 
        OrderAttributes storage orderAttributes = s._attributes[_orderID];
        
        require(orderAttributes.closedFlag == false);
        require(orderAttributes.depositedFlag == false, "deposit filled");
       
        // transfer fromTokenBalance to order
        // requires depositor to approve DepositOrder.sol trasnferFrom allowance 
        require(IERC20(orderAttributes.fromTokenAddress).transferFrom(msg.sender, orderAttributes.orderAddress, orderAttributes.tokenBalance), "owner to order balance transfer failed");
        
        orderAttributes.depositedFlag = true;
       
        // emit events                                                
        emit orderDeposited(_orderID);
    }
}
