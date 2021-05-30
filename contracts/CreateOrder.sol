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
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "./Interfaces/CreateOrderInterface.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {OrderInterface} from "./Interfaces/OrderInterface.sol";
import {CreateOrderInterface} from "./Interfaces/CreateOrderInterface.sol";
import {SettleOrderInterface} from "./Interfaces/SettleOrderInterface.sol";
import {CloseOrderInterface} from "./Interfaces/CloseOrderInterface.sol";
import {ModifyOrderInterface} from "./Interfaces/ModifyOrderInterface.sol";
import {DepositOrderInterface} from "./Interfaces/DepositOrderInterface.sol";
import {CreateOrder} from "./CreateOrder.sol";
import {Order} from "./Order.sol";

contract CreateOrder is CreateOrderInterface {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    
    Counters.Counter public orderCounter;
    
    uint256 public platformVolume;
    address nocturnalFinanceAddress;
    address WETH; 

    mapping(uint256 => Attributes) public _orders;
   
    event orderCreated(uint256 _orderID);
    
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance, address _WETH) {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
        nocturnalFinanceAddress = _nocturnalFinance;
        WETH = _WETH;
    }
    
    function createOrder(CreateParams calldata params) external override {
        require((params.fromTokenAddress == WETH) || (params.toTokenAddress == WETH), "pool must contain WETH");
        require((params.settlementGratuity >= 0) && (params.settlementGratuity < 10000));  
        Order nocturnalOrder = new Order(nocturnalFinanceAddress); 
        orderCounter.increment();
        
        OrderInterface(nocturnalFinance._contract(8)).mint(msg.sender, orderCounter.current());
       
        // set order URI using NocturnalFinance contract's orderURI()
      	OrderInterface(address(nocturnalOrder))._setTokenURI(orderCounter.current(), nocturnalFinance.orderURI());

        // set order attributes
        _orders[orderCounter.current()] = Attributes({
            orderAddress: address(nocturnalOrder),
            poolAddress: params.poolAddress,
            fromTokenAddress: params.fromTokenAddress,
            toTokenAddress: params.toTokenAddress,
            tokenBalance: params.tokenBalance,
            fromTokenValueInETH: 0,
            limitPrice: params.limitPrice,
            limitType: params.limitType,
            slippage: params.slippage, 
            settlementGratuity: params.settlementGratuity,
            depositedFlag: false,
            settledFlag: false
        }); 
        
        emit orderCreated(orderCounter.current());
    }
       
    function depositOrder(uint256 _orderID) public override {
        require(IERC20(_orders[_orderID].fromTokenAddress).balanceOf(msg.sender) >= _orders[_orderID].tokenBalance);
        DepositOrderInterface.DepositParams memory depositParams = DepositOrderInterface.DepositParams({
            orderAddress: _orders[_orderID].orderAddress,
            poolAddress: _orders[_orderID].poolAddress,
            fromTokenAddress: _orders[_orderID].fromTokenAddress,
            tokenBalance: _orders[_orderID].tokenBalance,
            depositedFlag: _orders[_orderID].depositedFlag
        });
        DepositOrderInterface(nocturnalFinance._contract(2)).depositOrder(_orderID, depositParams);
    }
    
    function settleOrder(uint256 _orderID) public override {
        SettleOrderInterface.SettleParams memory settleParams = SettleOrderInterface.SettleParams({
            orderAddress: _orders[_orderID].orderAddress,
            poolAddress: _orders[_orderID].poolAddress,
            fromTokenAddress: _orders[_orderID].fromTokenAddress,              
            tokenBalance: _orders[_orderID].tokenBalance,
            fromTokenValueInETH: _orders[_orderID].fromTokenValueInETH,
            limitPrice: _orders[_orderID].limitPrice,
            limitType: _orders[_orderID].limitType,
            slippage: _orders[_orderID].slippage,
            settlementGratuity: _orders[_orderID].settlementGratuity,
            depositedFlag: _orders[_orderID].depositedFlag,
            settledFlag: _orders[_orderID].settledFlag
        });
        SettleOrderInterface(nocturnalFinance._contract(3)).settleOrder(_orderID, settleParams);
    }
    
    function closeOrder(uint256 _orderID) public override {
        require(msg.sender == OrderInterface(_orders[_orderID].orderAddress).ownerOf(_orderID), "not order owner");
        CloseOrderInterface.CloseParams memory closeParams = CloseOrderInterface.CloseParams({
            orderAddress: _orders[_orderID].orderAddress,
            poolAddress: _orders[_orderID].poolAddress,
            fromTokenAddress: _orders[_orderID].fromTokenAddress,
            toTokenAddress: _orders[_orderID].toTokenAddress,
            tokenBalance: _orders[_orderID].tokenBalance,
            slippage: _orders[_orderID].slippage,
            depositedFlag: _orders[_orderID].depositedFlag,
            settledFlag: _orders[_orderID].settledFlag
        });
        CloseOrderInterface(nocturnalFinance._contract(4)).closeOrder(_orderID, closeParams);
    }
    
    function orderAttributes(uint256 _orderID) 
        public
        view override
        returns (
            address orderAddress,
            address poolAddress,
            address fromTokenAddress,
            address toTokenAddress,
            uint256 tokenBalance,
            uint256 fromTokenValueInETH,
            uint256 limitPrice,
            bool limitType,
            uint256 slippage,
            uint256 settlementGratuity,
            bool depositedFlag,
            bool settledFlag
        ) 
    {
        Attributes memory attributes = _orders[_orderID];
        return (
            attributes.orderAddress,
            attributes.poolAddress,
            attributes.fromTokenAddress,
            attributes.toTokenAddress,
            attributes.tokenBalance,
            attributes.fromTokenValueInETH,
            attributes.limitPrice,
            attributes.limitType,
            attributes.slippage,
            attributes.settlementGratuity,
            attributes.depositedFlag,
            attributes.settledFlag
        );
    }  
    
    function modifyOrderSlippage(uint256 _orderID, uint256 _slippage) public override {
        require(msg.sender == OrderInterface(_orders[_orderID].orderAddress).ownerOf(_orderID), "not order owner");
        ModifyOrderInterface(nocturnalFinance._contract(5)).modifySlippage(_orderID, _slippage);
    }
    
    function modifyOrderSettlementGratuity(uint256 _orderID, uint256 _gratuity) public override {
        require(msg.sender == OrderInterface(_orders[_orderID].orderAddress).ownerOf(_orderID), "not order owner");
        ModifyOrderInterface(nocturnalFinance._contract(5)).modifySettlementGratuity(_orderID, _gratuity);
    }
    
    function setTokenBalance(uint256 _orderID, uint256 _balance) public override {
        require(msg.sender == nocturnalFinance._contract(3), "not SettleOrder contract");
        _orders[_orderID].tokenBalance = _balance;
    }
    
    function setFromTokenValueInETH(uint256 _orderID, uint256 _valueInETH) public override {
        require(msg.sender == nocturnalFinance._contract(2), "not DepositOrder contract");
        _orders[_orderID].fromTokenValueInETH = _valueInETH;
    }
    
    function setDepositedFlag(uint256 _orderID, bool _flag) public override {
        require(msg.sender == nocturnalFinance._contract(2), "not DepositOrder contract");
        _orders[_orderID].depositedFlag = _flag;
    }
    
    function setSettledFlag(uint256 _orderID, bool _flag) public override {
        require(msg.sender == nocturnalFinance._contract(3), "not SettleOrder contract");
        _orders[_orderID].settledFlag =  _flag;
    }
    
    function setSlippage(uint256 _orderID, uint256 _slippage) public override {
        require(msg.sender == nocturnalFinance._contract(5), "not ModifyOrder contract");
        _orders[_orderID].slippage = _slippage;
    }
    
    function setSettlementGratuity(uint256 _orderID, uint256 _gratuity) public override {
        require(msg.sender == nocturnalFinance._contract(5), "not ModifyOrder contract");
        _orders[_orderID].settlementGratuity = _gratuity;
    }  
    
    
}
