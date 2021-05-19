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
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {OrderInterface} from "./Interfaces/OrderInterface.sol";
import {OrderCreatorInterface} from "./Interfaces/OrderCreatorInterface.sol";
import {OrderSettlerInterface} from "./Interfaces/OrderSettlerInterface.sol";
import {OrderFactoryInterface} from "./Interfaces/OrderFactoryInterface.sol";

contract OrderTransfer {
    using SafeMath for uint256;
    
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance) {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
    }
    
    function fromWETHCreate(uint256 dFee, address orderAddress) external {
        require(msg.sender == nocturnalFinance.orderCreatorAddress(), "only the OrderCreator contract can call");
        uint256 swapFromBalance = OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapFromTokenBalance(orderAddress);
        address swapFromTokenAddress = OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapFromTokenAddress(orderAddress);
        
        // 2)  If fromToken is WETH, transfer dFee WETH to Staking.sol then Transfer fromTokenBalance-dFee fromToken to order
        // must first obtain approval from msg.sender to transfer WETH to staking.sol and to order contract
        require(IERC20(swapFromTokenAddress).approve(address(this), swapFromBalance), "OrderTransfer contract approval failed");
        require(IERC20(swapFromTokenAddress).transferFrom(msg.sender, nocturnalFinance.sNoctAddress(), dFee), "creator to stakers dFee transfer failed");
        require(IERC20(swapFromTokenAddress).transferFrom(msg.sender, orderAddress, swapFromBalance.sub(dFee)), "creator to order balance transfer failed");
    }
    
    function toWETHCreate(uint256 dFee, address orderAddress, bool fromToken0) external {
        require(msg.sender == nocturnalFinance.orderCreatorAddress(), "only the OrderCreator contract can call");
        address swapFromTokenAddress = OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapFromTokenAddress(orderAddress);
        uint256 swapFromBalance = OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapFromTokenBalance(orderAddress);
        uint256 swapSlippage = OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapSlippage(orderAddress);
        address swapPoolAddress = OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapPoolAddress(orderAddress);
        
        // 3)  If toToken is WETH, Transfer fromTokenBalance fromToken to order, then swap dFee for WETH and send it to Staking.sol 
        require(IERC20(swapFromTokenAddress).approve(address(this), swapFromBalance), "OrderTransfer contract approval failed");
        require(IERC20(swapFromTokenAddress).transferFrom(msg.sender, orderAddress, swapFromBalance), "creator to order balance transfer failed");
        OrderInterface(nocturnalFinance.orderAddress()).orderSwap(swapPoolAddress, nocturnalFinance.sNoctAddress(), fromToken0, dFee, swapSlippage, 0);
    }
    
    function fromWETHSettle(address _address, bool fromToken0) external {
        require(msg.sender == nocturnalFinance.orderSettlerAddress(), "only the OrderSettler contract can call");
        address fromTokenAddress = OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapFromTokenAddress(_address);
        uint256 gratuity = OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapSettlementGratuity(_address);
        address poolAddress = OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapPoolAddress(_address);
        uint256 slippage = OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapSlippage(_address);
        uint256 fromTokenBalance = OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapFromTokenBalance(_address);
        
        OrderInterface(nocturnalFinance.orderAddress()).transferOrder(fromTokenAddress, msg.sender, gratuity);            
        OrderInterface(nocturnalFinance.orderAddress()).orderSwap(poolAddress, _address, fromToken0, slippage, fromTokenBalance.sub(gratuity), 0);  
    }

    function toWETHSettle(address _address, bool fromToken0) external {
        require(msg.sender == nocturnalFinance.orderSettlerAddress(), "only the OrderSettler contract can call");
        uint256 gratuity = OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapSettlementGratuity(_address);
        address poolAddress = OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapPoolAddress(_address);
        uint256 slippage = OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapSlippage(_address);
        uint256 fromTokenBalance = OrderFactoryInterface(nocturnalFinance.orderFactoryAddress()).swapFromTokenBalance(_address);
        
        OrderInterface(nocturnalFinance.orderAddress()).orderSwap(poolAddress, msg.sender, fromToken0, slippage, gratuity, 0);
        OrderInterface(nocturnalFinance.orderAddress()).orderSwap(poolAddress, _address, fromToken0, slippage, fromTokenBalance.sub(gratuity), 0);
    }
}
