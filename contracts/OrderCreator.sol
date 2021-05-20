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

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {OracleInterface} from "./Interfaces/OracleInterface.sol";
import {OrderInterface} from "./Interfaces/OrderInterface.sol";
import {OrderFactoryInterface} from "./Interfaces/OrderFactoryInterface.sol";
import {Order} from "./Order.sol";
import {OrderTransferInterface} from "./Interfaces/OrderTransferInterface.sol";

contract OrderCreator {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    
    Counters.Counter public orderCounter;
    
    uint256 public platformVolume;
    uint256 internal constant bPDivisor = 10000;  // 100th of a bip
    address WETH; 
   
    // may include all attributes in events
    // someone may want to analyze trade data in future
    event orderCreated(uint256 _orderID, address _orderAddress, uint256 _settlementGratuity);
    
    NocturnalFinanceInterface public nocturnalFinance;
    IUniswapV3Pool public pool;
    
    constructor(address _nocturnalFinance, address _WETH) {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
        WETH = _WETH;
    }
    
    function createLimitOrder(
            address _swapPoolAddress, 
            address _swapFromTokenAddress, 
            address _swapToTokenAddress, 
            uint256 _swapFromTokenBalance, 
            uint256 _swapLimitPrice,
            uint256 _swapSlippage,
            bool _swapAbove,
            uint256 _swapSettlementGratuity) external {
        require(msg.sender == nocturnalFinance.orderFactoryAddress(), "caller is not order factory");
        require((_swapFromTokenAddress == WETH) || (_swapToTokenAddress == WETH), "pool must contain WETH");
        require(IERC20(_swapFromTokenAddress).balanceOf(msg.sender) >= _swapFromTokenBalance);
        require((_swapSettlementGratuity >= 0) && (_swapSettlementGratuity < 100));  
        Order nocturnalOrder = new Order("Nocturnal Order", "oNOCT"); 
        orderCounter.increment();
        
        OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).setOrderID(address(nocturnalOrder), orderCounter.current());
        OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).setOrderPoolAddress(address(nocturnalOrder), _swapPoolAddress);
        OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).setOrderFromTokenAddress(address(nocturnalOrder), _swapFromTokenAddress);
        OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).setOrderToTokenAddress(address(nocturnalOrder), _swapToTokenAddress);
        OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).setOrderFromTokenBalance(address(nocturnalOrder), _swapFromTokenBalance);
        OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).setOrderLimitPrice(address(nocturnalOrder), _swapLimitPrice);
        OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).setOrderLimitType(address(nocturnalOrder), _swapAbove);
        OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).setOrderSwapSlippage(address(nocturnalOrder), _swapSlippage);
        OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).setOrderSettlementGratuity(address(nocturnalOrder), _swapSettlementGratuity);

        OrderInterface(nocturnalFinance.orderAddress())._mint(msg.sender, orderCounter.current());
        
        // set order URI using initializer contract's orderURI() string
      	OrderInterface(nocturnalFinance.orderAddress())._setTokenURI(orderCounter.current(), nocturnalFinance.getURI());
      
        pool = IUniswapV3Pool(_swapPoolAddress);        

        // 1)  Calculate dFee
        uint256 dFee = _swapFromTokenBalance.mul(nocturnalFinance.depositRate()).div(bPDivisor);
        
        bool fromToken0;
        if (pool.token0() == _swapFromTokenAddress) {
            fromToken0 = true;
        } else {
            fromToken0 = false;
        }
        
        uint256 cPrice;

        // 2)  If fromToken is WETH, transfer dFee WETH to Staking.sol then Transfer fromTokenBalance.min(dFee) fromToken to order
        if (_swapFromTokenAddress == WETH) {
            OrderTransferInterface(nocturnalFinance.orderTransferAddress()).fromWETHCreate(dFee, address(nocturnalOrder));
            // get fromTokenBalance value in ETH for tracking platform volume
            OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).setOrderFromTokenValueInETH(address(nocturnalOrder), _swapFromTokenBalance);
        // 3)  If toToken is WETH, swap dFee for WETH and send it to Staking.sol then Transfer fromTokenBalance-dFee fromToken to order
        } else if ((_swapToTokenAddress == WETH) ) {
            OrderTransferInterface(nocturnalFinance.orderTransferAddress()).toWETHCreate(dFee, address(nocturnalOrder), pool.token0() == _swapFromTokenAddress);
            // get fromTokenBalance value in ETH for tracking platform volume
            if (fromToken0 == true) {
                // get reciprocal of current price
                cPrice = OracleInterface(nocturnalFinance.oracleAddress()).getCurrentPriceReciprocal(_swapPoolAddress);
            } else {           
                // get current price    
                cPrice = OracleInterface(nocturnalFinance.oracleAddress()).getCurrentPrice(_swapPoolAddress);                             
            }
            OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).setOrderFromTokenValueInETH(address(nocturnalOrder), _swapFromTokenBalance.mul(cPrice));
        }
        
        // update Order fromTokenBalance attribute for settlement
        OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).setOrderFromTokenBalance(address(nocturnalOrder), _swapFromTokenBalance.sub(dFee));
        // emit events                                                
        emit orderCreated(orderCounter.current(), address(nocturnalOrder), _swapSettlementGratuity);
    }
}
