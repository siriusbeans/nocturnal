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
import "./Interfaces/SettleOrderInterface.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {NoctInterface} from "./Interfaces/NoctInterface.sol";
import {OracleInterface} from "./Interfaces/OracleInterface.sol";
import {OrderInterface} from "./Interfaces/OrderInterface.sol";
import {CreateOrderInterface} from "./Interfaces/CreateOrderInterface.sol";
import {SettleOrderTransferInterface} from "./Interfaces/SettleOrderTransferInterface.sol";
import {DistributeRewardsInterface} from "./Interfaces/DistributeRewardsInterface.sol";

contract SettleOrder is SettleOrderInterface {
    using SafeMath for uint256;
    
    uint256 public platformVolume;
    address WETH; 

    event orderSettled(uint256 _orderID);
    event platformVolumeUpdate(uint256 _volume);
    
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance, address _WETH) {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
        WETH = _WETH;
    }
    
    function settleOrder(uint256 _orderID, SettleParams calldata params, address settlerAddress) external override {
        require(msg.sender == nocturnalFinance._contract(1), "caller is not order manager address");
        require(params.depositedFlag == true, "order not deposited");
        require(params.settledFlag == false, "order settled");
        uint256 currentPrice;
        uint256 noctVol;
        
        // the limit price value returned by the front end is denominated by ETH
        // so choose current pool price with WETH in denominator
        if (IUniswapV3Pool(params.poolAddress).token0() == WETH) {
            currentPrice = OracleInterface(nocturnalFinance._contract(7)).getCurrentPriceReciprocal(params.poolAddress);
        } else {
            currentPrice = OracleInterface(nocturnalFinance._contract(7)).getCurrentPrice(params.poolAddress);
        }
        
        if (params.limitType == true) {
            require(currentPrice >= params.limitPrice, "limit not met");
        } else {
            require(currentPrice <= params.limitPrice, "limit not met");
        }
        
        SettleOrderTransferInterface.SettleTransferParams memory settleTransferParams = SettleOrderTransferInterface.SettleTransferParams({
            orderAddress: params.orderAddress,
            poolAddress: params.poolAddress,
            fromTokenAddress: params.fromTokenAddress,
            toTokenAddress: params.toTokenAddress,
            tokenBalance: params.tokenBalance,
            amountOutMin: params.amountOutMin,
            settlementGratuity: params.settlementGratuity,
            depositedFlag: params.depositedFlag
        });
        
        // perform swap + send gratuity + send fee
        if (params.fromTokenAddress == WETH) {
            noctVol = SettleOrderTransferInterface(nocturnalFinance._contract(6)).fromWETHSettle(_orderID, settleTransferParams, settlerAddress);        
        } else {
            noctVol = SettleOrderTransferInterface(nocturnalFinance._contract(6)).toWETHSettle(_orderID, settleTransferParams, settlerAddress);
        }
                   
        // distribute the NOCT rewards to the settler and the creator 
        address orderOwnerAddress = OrderInterface(nocturnalFinance._contract(8)).ownerOf(_orderID);
        DistributeRewardsInterface(nocturnalFinance._contract(11)).distributeNOCT(noctVol, orderOwnerAddress, settlerAddress);
        
        // increment platform volume tracker counter
        platformVolume.add(noctVol);
        
        // emit events
        emit orderSettled(_orderID);
        emit platformVolumeUpdate(platformVolume);
    }
}
