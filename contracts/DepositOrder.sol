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
import "./Interfaces/DepositOrderInterface.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {OrderInterface} from "./Interfaces/OrderInterface.sol";
import {CreateOrderInterface} from "./Interfaces/CreateOrderInterface.sol";
import {OracleInterface} from "./Interfaces/OracleInterface.sol";

contract DepositOrder is DepositOrderInterface {
    using SafeMath for uint256;

    address WETH;

    event orderDeposited(uint256 _orderID);
    
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance, address _WETH) {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
        WETH = _WETH;
    }

    function depositOrder(uint256 _orderID, DepositParams calldata params, address _depositor) public override {
        require(msg.sender == nocturnalFinance._contract(1));
        require(params.closedFlag == false);
        require(params.depositedFlag == false, "deposit filled");
       
        // transfer fromTokenBalance to order
        // requires depositor to approve DepositOrder.sol trasnferFrom allowance 
        require(IERC20(params.fromTokenAddress).transferFrom(_depositor, params.orderAddress, params.tokenBalance), "owner to order balance transfer failed");
        
        CreateOrderInterface(nocturnalFinance._contract(1)).setAttributes(_orderID, params.tokenBalance);  
       
        // emit events                                                
        emit orderDeposited(_orderID);
    }
}
