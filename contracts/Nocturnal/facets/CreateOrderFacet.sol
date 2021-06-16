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

import "@openzeppelin/contracts/utils/Counters.sol";
import {CreateOrderParams, OrderAttributes, AppStorage, LibAppStorage} from "../libraries/LibAppStorage.sol";
import {OrderInterface} from "../Interfaces/OrderInterface.sol";
import {Order} from "../Order.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";

contract CreateOrderFacet {
    AppStorage internal s;
    
    using Counters for Counters.Counter;
    
    Counters.Counter public orderCounter;
    
    address WETH; 
   
    event orderCreated(uint256 _orderID);
    
    constructor(address _WETH) {
        WETH = _WETH;
    }
    
    function createOrder(CreateOrderParams calldata params) external {
        require((params.fromTokenAddress == WETH) || (params.toTokenAddress == WETH));
        
        // AppStorage 
        OrderAttributes storage orderAttributes = s._attributes[orderCounter.current()];
        
        Order nocturnalOrder = new Order(s.orderURI); 
        orderCounter.increment();

        // Contracts.orderAddress from AppStorage will replace nocturnalFinance._contract(8)
        OrderInterface(s.orderAddress).mint(LibMeta.msgSender(), orderCounter.current());
        
        orderAttributes.orderAddress = address(nocturnalOrder);
        orderAttributes.poolAddress = params.poolAddress;
        orderAttributes.fromTokenAddress = params.fromTokenAddress;
        orderAttributes.toTokenAddress = params.toTokenAddress;
        orderAttributes.tokenBalance = params.tokenBalance;
        orderAttributes.limitPrice = params.limitPrice;
        orderAttributes.limitType = params.limitType;
        orderAttributes.amountOutMin = params.amountOutMin;
        orderAttributes.settlementGratuity = params.settlementGratuity;
        orderAttributes.depositedFlag = false;
        orderAttributes.settledFlag = false;
        orderAttributes.closedFlag = false;

        emit orderCreated(orderCounter.current());      
    }
}
