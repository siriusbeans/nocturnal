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
import {OrderCreatorInterface} from "./Interfaces/OrderCreatorInterface.sol";
import {OrderSettlerInterface} from "./Interfaces/OrderSettlerInterface.sol";
import {OrderCloserInterface} from "./Interfaces/OrderCloserInterface.sol";
import {OrderModifierInterface} from "./Interfaces/OrderModifierInterface.sol";

contract OrderFactory {
    
    mapping(address => uint256) swapOrderID;
    mapping(address => address) swapPoolAddress;
    mapping(address => address) swapFromTokenAddress;
    mapping(address => address) swapToTokenAddress;
    mapping(address => uint256) swapFromTokenBalance;
    mapping(address => uint256) swapToTokenBalance;
    mapping(address => uint256) swapFromTokenValueInETH;
    mapping(address => uint256) swapLimitPrice;
    mapping(address => bool) swapAbove;
    mapping(address => uint256) swapSlippage;
    mapping(address => uint256) swapSettlementGratuity;
    mapping(address => bool) swapSettledFlag;
    
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance) {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
    }
    
    function createLimitOrder(
            address _swapPoolAddress, 
            address _swapFromTokenAddress, 
            address _swapToTokenAddress, 
            uint256 _swapFromTokenBalance, 
            uint256 _swapLimitPrice,
            uint256 _swapSlippage,
            bool _swapAbove,
            uint256 _swapSettlementGratuity) public {
        OrderCreatorInterface(nocturnalFinance.orderCreatorAddress()).createLimitOrder(_swapPoolAddress, 
                                                                                       _swapFromTokenAddress, 
                                                                                       _swapToTokenAddress, 
                                                                                       _swapFromTokenBalance, 
                                                                                       _swapLimitPrice, 
                                                                                       _swapSlippage, 
                                                                                       _swapAbove, 
                                                                                       _swapSettlementGratuity); 
    }
    
    function settleLimitOrder(address _address) public {
        OrderSettlerInterface(nocturnalFinance.orderSettlerAddress()).settleLimitOrder(_address);
    }
    
    function closeLimitOrder(address _address) public {
        OrderCloserInterface(nocturnalFinance.orderCloserAddress()).closeLimitOrder(_address);
    }
    
    

    function setOrderID(address _orderAddress, uint256 _orderID) public {
        require(msg.sender == nocturnalFinance.orderCreatorAddress(), "only OrderCreator contract can set order attribute");
        swapOrderID[_orderAddress] = _orderID;
    }
    
    function setOrderPoolAddress(address _orderAddress, address _poolAddress) public {
        require(msg.sender == nocturnalFinance.orderCreatorAddress(), "only OrderCreator contract can set order attribute");
        swapPoolAddress[_orderAddress] = _poolAddress;
    }
    
    function setOrderFromTokenAddress(address _orderAddress, address _tokenAddress) public {
        require(msg.sender == nocturnalFinance.orderCreatorAddress(), "only OrderCreator contract can set order attribute");
        swapFromTokenAddress[_orderAddress] = _tokenAddress;
    }
    
    function setOrderFromTokenBalance(address _orderAddress, uint256 _tokenBalance) public {
        require(msg.sender == nocturnalFinance.orderCreatorAddress(), "only OrderCreator contract can set order attribute");
        swapFromTokenBalance[_orderAddress] = _tokenBalance;
    }
    
    function setOrderToTokenAddress(address _orderAddress, address _tokenAddress) public {
        require(msg.sender == nocturnalFinance.orderCreatorAddress(), "only OrderCreator contract can set order attribute");
        swapToTokenAddress[_orderAddress] = _tokenAddress;
    }
    
    function setOrderToTokenBalance(address _orderAddress, uint256 _tokenBalance) public {
        require(msg.sender == nocturnalFinance.orderCreatorAddress(), "only OrderCreator contract can set order attribute");
        swapToTokenBalance[_orderAddress] = _tokenBalance;
    }
    
    function setOrderFromTokenValueInETH(address _orderAddress, uint256 _balance) public {
         require(msg.sender == nocturnalFinance.orderCreatorAddress(), "only OrderCreator contract can set order attribute");   
         swapFromTokenValueInETH[_orderAddress] = _balance;
    }
    
    function setOrderLimitPrice(address _orderAddress, uint256 _limitPrice) public {
        require(msg.sender == nocturnalFinance.orderCreatorAddress(), "only OrderCreator contract can set order attribute");
        swapLimitPrice[_orderAddress] = _limitPrice;
    }
    
    function setOrderLimitType(address _orderAddress, bool _limitType) public {
        require(msg.sender == nocturnalFinance.orderCreatorAddress(), "only OrderCreator contract can set order attribute");
        swapAbove[_orderAddress] = _limitType;
    }
    
    function setOrderSwapSlippage(address _orderAddress, uint256 _slippage) public {
        require(msg.sender == nocturnalFinance.orderCreatorAddress(), "only OrderCreator contract can set order attribute");
        swapSlippage[_orderAddress] = _slippage;
    }
    
    function setOrderSettlementGratuity(address _orderAddress, uint256 _gratuity) public {
        require(msg.sender == nocturnalFinance.orderCreatorAddress(), "only OrderCreator contract can set order attribute");
        swapSettlementGratuity[_orderAddress] = _gratuity;
    }
    
    function setOrderSettledFlag(address _orderAddress, bool _settleFlag) public {
        require(msg.sender == nocturnalFinance.orderCreatorAddress(), "only OrderCreator contract can set order attribute");
        swapSettledFlag[_orderAddress] = _settleFlag;
    }



    function getOrderID(address _orderAddress) public view returns (uint256) {
        return swapOrderID[_orderAddress];
    }
    
    function getOrderPoolAddress(address _orderAddress) public view returns (address) {
        return swapPoolAddress[_orderAddress];
    }
    
    function getOrderFromTokenAddress(address _orderAddress) public view returns (address) {
        return swapFromTokenAddress[_orderAddress];
    }
    
    function getOrderFromTokenBalance(address _orderAddress) public view returns (uint256) {
        return swapFromTokenBalance[_orderAddress];
    }
    
    function getOrderToTokenAddress(address _orderAddress) public view returns (address) {
        return swapToTokenAddress[_orderAddress];
    }
    
    function getOrderToTokenBalance(address _orderAddress) public view returns (uint256) {
        return swapToTokenBalance[_orderAddress];
    }
    
    function getOrderLimitPrice(address _orderAddress) public view returns (uint256) {
        return swapLimitPrice[_orderAddress];
    }
    
    function getOrderLimitType(address _orderAddress) public view returns (bool) {
        return swapAbove[_orderAddress];
    }
    
    function getOrderSwapSlippage(address _orderAddress) public view returns (uint256) {
        return swapSlippage[_orderAddress];
    }
    
    function getOrderSettlementGratuity(address _orderAddress) public view returns (uint256) {
        return swapSettlementGratuity[_orderAddress];
    }
    
    function getOrderSettledFlag(address _orderAddress) public view returns (bool) {
        return swapSettledFlag[_orderAddress];
    }
    
}
