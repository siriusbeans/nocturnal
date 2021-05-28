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
    uint256 internal constant bPDivisor = 10000;  // 100th of a bip
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
        (,,,,,,,,,,bool depositedFlag,) = OrderManagerInterface(nocturnalFinance.orderManagerAddress()).getOrderAttributes(_orderID);
        require(depositedFlag == true, "deposit filled");
        (,,,,,,,,,,,bool settledFlag) = OrderManagerInterface(nocturnalFinance.orderManagerAddress()).getOrderAttributes(_orderID);
        require(settledFlag == false, "order settled");
        (,,,,,,,bool limitType,,,,) = OrderManagerInterface(nocturnalFinance.orderManagerAddress()).getOrderAttributes(_orderID);
        (,,,,,,uint256 limitPrice,,,,,) = OrderManagerInterface(nocturnalFinance.orderManagerAddress()).getOrderAttributes(_orderID);
        (,,address fromTokenAddress,,,,,,,,,) = OrderManagerInterface(nocturnalFinance.orderManagerAddress()).getOrderAttributes(_orderID);
        (,address poolAddress,,,,,,,,,,) = OrderManagerInterface(nocturnalFinance.orderManagerAddress()).getOrderAttributes(_orderID);
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
      
        (,,,,uint256 tokenBalance,,,,,,,) = OrderManagerInterface(nocturnalFinance.orderManagerAddress()).getOrderAttributes(_orderID);
        (,,,,,,,,,uint256 settlementGratuity,,) = OrderManagerInterface(nocturnalFinance.orderManagerAddress()).getOrderAttributes(_orderID);
        (address orderAddress,,,,,,,,,,,) = OrderManagerInterface(nocturnalFinance.orderManagerAddress()).getOrderAttributes(_orderID);        
        address orderOwnerAddress = OrderInterface(orderAddress).ownerOf(_orderID);
        (,,,,,uint256 sFTVIE,,,,,,) = OrderManagerInterface(nocturnalFinance.orderManagerAddress()).getOrderAttributes(_orderID);
        
        // calculate gratuity
        uint256 gratuity = tokenBalance.mul(settlementGratuity).div(bPDivisor);

        // if fromToken is WETH, deduct gratuity from WETH and send to settler before performing the swap
        if (fromTokenAddress == WETH) {
            SettleOrderTransferInterface(nocturnalFinance.settleOrderTransferAddress()).fromWETHSettle(_orderID);        
        // if toToken is WETH, perform the swap and then deduct gratuity from WETH and send to settler
        } else {
            SettleOrderTransferInterface(nocturnalFinance.settleOrderTransferAddress()).toWETHSettle(_orderID);
        }
        // update Order toTokenBalance attribute for order closure
        CreateOrderInterface(nocturnalFinance.createOrderAddress()).setTokenBalance(_orderID, tokenBalance.sub(gratuity));
        // set swap settle flag to true
        CreateOrderInterface(nocturnalFinance.createOrderAddress()).setSettledFlag(_orderID, true);            
        // distribute the NOCT rewards to the settler and the creator 
        DistributeRewardsInterface(nocturnalFinance.distributeRewardsAddress()).distributeNOCT(sFTVIE, orderOwnerAddress);
        // increment platform volume tracker counter
        platformVolume.add(sFTVIE);
        
        // emit events
        emit orderSettled(_orderID);
        emit platformVolumeUpdate(platformVolume);
    }
}
