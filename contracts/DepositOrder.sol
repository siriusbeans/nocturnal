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
import {OrderManagerInterface} from "./Interfaces/OrderManagerInterface.sol";
import {OrderInterface} from "./Interfaces/OrderInterface.sol";
import {ValueInEthInterface} from "./Interfaces/ValueInEthInterface.sol";
import {CreateOrderInterface} from "./Interfaces/CreateOrderInterface.sol";

contract CreateOrder {

    event orderDeposited(uint256 _orderID);
    
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance) {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
    }

    function depositOrder(uint256 _orderID) public {
        require(msg.sender == nocturnalFinance.orderManagerAddress());
        (address orderAddress,address poolAddress,address fromTokenAddress,,uint256 tokenBalance,,,,,,bool depositedFlag,) = CreateOrderInterface(nocturnalFinance.createOrderAddress()).orderAttributes(_orderID);
        require(depositedFlag == false, "deposit filled");
        address orderOwnerAddress = OrderInterface(orderAddress).ownerOf(_orderID);
       
        // transfer fromTokenBalance to order
        // requires orderOwner to approve DepositOrder.sol trasnferFrom allowance 
        require(IERC20(fromTokenAddress).transferFrom(orderOwnerAddress, orderAddress, tokenBalance), "owner to order balance transfer failed");
       
        // set fromTokenBalance in ETH attribute
        CreateOrderInterface(nocturnalFinance.createOrderAddress()).setFromTokenValueInETH(_orderID, ValueInEthInterface(nocturnalFinance.valueInEthAddress()).getValueInEth(fromTokenAddress, tokenBalance, poolAddress));

        // set depositedFlag
        CreateOrderInterface(nocturnalFinance.createOrderAddress()).setSettledFlag(_orderID, true);

        // emit events                                                
        emit orderDeposited(_orderID);
    }
}
