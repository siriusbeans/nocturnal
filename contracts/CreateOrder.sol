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
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "./Interfaces/CreateOrderInterface.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {OrderInterface} from "./Interfaces/OrderInterface.sol";
import {CreateOrderInterface} from "./Interfaces/CreateOrderInterface.sol";
import {SettleOrderInterface} from "./Interfaces/SettleOrderInterface.sol";
import {CloseOrderInterface} from "./Interfaces/CloseOrderInterface.sol";
import {DepositOrderInterface} from "./Interfaces/DepositOrderInterface.sol";
import {Order} from "./Order.sol";

contract CreateOrder is CreateOrderInterface {
    using Counters for Counters.Counter;
    
    Counters.Counter public orderCounter;
    
    address nocturnalFinanceAddress;
    address WETH; 

    mapping(uint256 => Attributes) private _orders;
   
    event orderCreated(uint256 _orderID);
    
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance, address _WETH) {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
        nocturnalFinanceAddress = _nocturnalFinance;
        WETH = _WETH;
    }
    
    function createOrder(CreateParams calldata params) external override {
        require((params.fromTokenAddress == WETH) || (params.toTokenAddress == WETH));
        // ensure settlementGratuity is less than 100% of order value (in ETH) 
        // if (params.fromTokenAddress == WETH) {
        //     require(params.settlementGratuity < );
        // } else {
        //     require(params.settlementGratuity < );
        Order nocturnalOrder = new Order(nocturnalFinanceAddress); 
        orderCounter.increment();
        
        OrderInterface(nocturnalFinance._contract(8)).mint(msg.sender, orderCounter.current());
       
        // set order attributes
        _orders[orderCounter.current()] = Attributes({
            orderAddress: address(nocturnalOrder),
            poolAddress: params.poolAddress,
            fromTokenAddress: params.fromTokenAddress,
            toTokenAddress: params.toTokenAddress,
            tokenBalance: params.tokenBalance,
            limitPrice: params.limitPrice,
            limitType: params.limitType,
            amountOutMin: params.amountOutMin,
            settlementGratuity: params.settlementGratuity,
            depositedFlag: false,
            settledFlag: false,
            closedFlag: false
        }); 
        
        emit orderCreated(orderCounter.current());
    }
       
    function depositOrder(uint256 _orderID) public override {
        // removed due to contract size contraints
        //require(IERC20(_orders[_orderID].fromTokenAddress).balanceOf(msg.sender) >= _orders[_orderID].tokenBalance);
        DepositOrderInterface.DepositParams memory depositParams = DepositOrderInterface.DepositParams({
            orderAddress: _orders[_orderID].orderAddress,
            poolAddress: _orders[_orderID].poolAddress,
            fromTokenAddress: _orders[_orderID].fromTokenAddress,
            tokenBalance: _orders[_orderID].tokenBalance,
            depositedFlag: _orders[_orderID].depositedFlag,
            closedFlag: _orders[_orderID].closedFlag
        });
        DepositOrderInterface(nocturnalFinance._contract(2)).depositOrder(_orderID, depositParams, msg.sender); 
    }
    
    function settleOrder(uint256 _orderID) public override {
        SettleOrderInterface.SettleParams memory settleParams = SettleOrderInterface.SettleParams({
            orderAddress: _orders[_orderID].orderAddress,
            poolAddress: _orders[_orderID].poolAddress,
            fromTokenAddress: _orders[_orderID].fromTokenAddress,       
            toTokenAddress: _orders[_orderID].toTokenAddress,       
            tokenBalance: _orders[_orderID].tokenBalance,
            limitPrice: _orders[_orderID].limitPrice,
            limitType: _orders[_orderID].limitType,
            amountOutMin: _orders[_orderID].amountOutMin,
            settlementGratuity: _orders[_orderID].settlementGratuity,
            depositedFlag: _orders[_orderID].depositedFlag,
            settledFlag: _orders[_orderID].settledFlag
        });
        SettleOrderInterface(nocturnalFinance._contract(3)).settleOrder(_orderID, settleParams, msg.sender); 
    }
    
    function closeOrder(uint256 _orderID) public override {
        require(msg.sender == OrderInterface(nocturnalFinance._contract(8)).ownerOf(_orderID));
        CloseOrderInterface.CloseParams memory closeParams = CloseOrderInterface.CloseParams({
            orderAddress: _orders[_orderID].orderAddress,
            poolAddress: _orders[_orderID].poolAddress,
            fromTokenAddress: _orders[_orderID].fromTokenAddress,
            toTokenAddress: _orders[_orderID].toTokenAddress,
            tokenBalance: _orders[_orderID].tokenBalance,
            depositedFlag: _orders[_orderID].depositedFlag,
            settledFlag: _orders[_orderID].settledFlag,
            closedFlag: _orders[_orderID].closedFlag
        });
        CloseOrderInterface(nocturnalFinance._contract(4)).closeOrder(_orderID, closeParams); 
    }
    
    
    function orderAttributes(uint256 _orderID) 
        public
        view 
        returns (
            address orderAddress,
            address poolAddress,
            address fromTokenAddress,
            address toTokenAddress,
            uint256 tokenBalance,
            uint256 limitPrice,
            bool limitType,
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
            attributes.limitPrice,
            attributes.limitType,
            attributes.settlementGratuity,
            attributes.depositedFlag,
            attributes.settledFlag
        );
    } 

    function setAttributes(uint256 _orderID, uint256 _balance) public override {
        // removed due to contract size contraints
        //require(msg.sender == nocturnalFinance._contract(2) || msg.sender == nocturnalFinance._contract(6) || msg.sender == nocturnalFinance._contract(4));
        if (msg.sender == nocturnalFinance._contract(2)) {
            _orders[_orderID].depositedFlag = true;
        } else if (msg.sender == nocturnalFinance._contract(6)) {
            _orders[_orderID].tokenBalance = _balance; 
            _orders[_orderID].settledFlag = true;
        }  else if (msg.sender == nocturnalFinance._contract(4)) {
            _orders[_orderID].tokenBalance = _balance;
            _orders[_orderID].closedFlag = true;
        }
    }
}
