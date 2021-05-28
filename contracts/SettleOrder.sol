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

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {NoctInterface} from "./Interfaces/NoctInterface.sol";
import {OracleInterface} from "./Interfaces/OracleInterface.sol";
import {OrderInterface} from "./Interfaces/OrderInterface.sol";
import {OrderManagerInterface} from "./Interfaces/OrderManagerInterface.sol";
import {CreateOrderInterface} from "./Interfaces/CreateOrderInterface.sol";
import {SettleOrderTransferInterface} from "./Interfaces/SettleOrderTransferInterface.sol";
import {DistributeRewardsInterface} from "./Interfaces/DistributeRewardsInterface.sol";

contract SettleOrder {
    using SafeMath for uint256;
    
    uint256 public platformVolume;
    address WETH; 
    
    // may include all attributes in events
    // someone may want to analyze trade data in future
    event orderSettled(uint256 _orderID);
    event platformVolumeUpdate(uint256 _volume);
    
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance, address _WETH) {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
        WETH = _WETH;
    }
    
    function settleOrder(uint256 _orderID) external {
        require(msg.sender == nocturnalFinance.orderManagerAddress(), "caller is not order manager address");
        (address orderAddress,address poolAddress,address fromTokenAddress,,uint256 tokenBalance,uint256 sFTVIE,uint256 limitPrice,bool limitType,,uint256 settlementGratuity,bool depositedFlag,bool settledFlag) = CreateOrderInterface(nocturnalFinance.createOrderAddress()).orderAttributes(_orderID);
        require(depositedFlag == true, "deposit filled");
        require(settledFlag == false, "order settled");
        uint256 currentPrice;
        
        // the value of the limit returned by front end 
        // is a function of token0 (fromToken or toToken)
        if (IUniswapV3Pool(poolAddress).token0() == fromTokenAddress) {
            currentPrice = OracleInterface(nocturnalFinance.oracleAddress()).getCurrentPrice(poolAddress);
        } else {
            // obtain the reciprocal of below value
            currentPrice = OracleInterface(nocturnalFinance.oracleAddress()).getCurrentPriceReciprocal(poolAddress);
        }
        
        if (limitType == true) {
            require(currentPrice >= limitPrice, "limit not met");
        } else if (limitType == false) {
            require(currentPrice <= limitPrice, "limit not met");
        }

        // if fromToken is WETH, deduct gratuity from WETH and send to settler before performing the swap
        if (fromTokenAddress == WETH) {
            SettleOrderTransferInterface(nocturnalFinance.settleOrderTransferAddress()).fromWETHSettle(_orderID);        
        // if toToken is WETH, perform the swap and then deduct gratuity from WETH and send to settler
        } else {
            SettleOrderTransferInterface(nocturnalFinance.settleOrderTransferAddress()).toWETHSettle(_orderID);
        }
        // set swap settle flag to true
        CreateOrderInterface(nocturnalFinance.createOrderAddress()).setSettledFlag(_orderID, true); 
                   
        // distribute the NOCT rewards to the settler and the creator 
        address orderOwnerAddress = OrderInterface(orderAddress).ownerOf(_orderID);
        DistributeRewardsInterface(nocturnalFinance.distributeRewardsAddress()).distributeNOCT(sFTVIE, orderOwnerAddress);
        
        // increment platform volume tracker counter
        platformVolume.add(sFTVIE);
        
        // emit events
        emit orderSettled(_orderID);
        emit platformVolumeUpdate(platformVolume);
    }
}
