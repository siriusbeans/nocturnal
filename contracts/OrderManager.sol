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
import {CreateOrderInterface} from "./Interfaces/CreateOrderInterface.sol";
import {SettleOrderInterface} from "./Interfaces/SettleOrderInterface.sol";
import {CloseOrderInterface} from "./Interfaces/CloseOrderInterface.sol";
import {ModifyOrderInterface} from "./Interfaces/ModifyOrderInterface.sol";
import {OrderInterface} from "./Interfaces/OrderInterface.sol";
import {DepositOrderInterface} from "./Interfaces/DepositOrderInterface.sol";

contract OrderManager {

    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance) {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
    }
    
    function createOrder(
        address poolAddress,
        address fromTokenAddress,
        address toTokenAddress,
        uint256 tokenBalance,
        uint256 limitPrice,
        uint256 slippage,
        bool limitType,
        uint256 settlementGratuity
    ) public {
        CreateOrderInterface(nocturnalFinance.createOrderAddress()).createOrder(
            poolAddress,
            fromTokenAddress,
            toTokenAddress,
            tokenBalance,
            limitPrice,
            slippage,
            limitType,
            settlementGratuity
        );
    }
    
    function depositOrder(uint256 _orderID) public {
        DepositOrderInterface(nocturnalFinance.depositOrderAddress()).depositOrder(_orderID);
    }
    
    function settleOrder(uint256 _orderID) public {
        SettleOrderInterface(nocturnalFinance.settleOrderAddress()).settleOrder(_orderID);
    }
    
    function closeOrder(uint256 _orderID) public {
        (address orderAddress,,,,,,,,,,,) = getOrderAttributes(_orderID);        
        require(msg.sender == OrderInterface(orderAddress).ownerOf(_orderID), "not order owner");
        CloseOrderInterface(nocturnalFinance.closeOrderAddress()).closeOrder(_orderID);
    }

    function getOrderAttributes(uint256 _orderID) public view 
        returns (address , address, address, address, uint256, uint256, uint256, bool, uint256, uint256, bool, bool) 
    {
        return CreateOrderInterface(nocturnalFinance.createOrderAddress()).orderAttributes(_orderID);
    }
    
    function modifyOrderSlippage(uint256 _orderID, uint256 _slippage) public {
        (address orderAddress,,,,,,,,,,,) = getOrderAttributes(_orderID);    
        require(msg.sender == OrderInterface(orderAddress).ownerOf(_orderID), "not order owner");
        ModifyOrderInterface(nocturnalFinance.modifyOrderAddress()).modifySlippage(_orderID, _slippage);
    }
    
    function modifyOrderSettlementGratuity(uint256 _orderID, uint256 _gratuity) public {
        (address orderAddress,,,,,,,,,,,) = getOrderAttributes(_orderID);    
        require(msg.sender == OrderInterface(orderAddress).ownerOf(_orderID), "not order owner");
        ModifyOrderInterface(nocturnalFinance.modifyOrderAddress()).modifySettlementGratuity(_orderID, _gratuity);
    }
}
