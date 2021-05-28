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
import {OrderManagerInterface} from "./Interfaces/OrderManagerInterface.sol";
import {Order} from "./Order.sol";
import {ValueInEthInterface} from "./Interfaces/ValueInEthInterface.sol";

contract CreateOrder {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    
    Counters.Counter public orderCounter;
    
    uint256 public platformVolume;
    address nocturnalFinanceAddress;
    address WETH; 
    
    struct Attributes {
        address orderAddress;
        address poolAddress;
        address fromTokenAddress;
        address toTokenAddress;
        uint256 tokenBalance;
        uint256 fromTokenValueInETH;
        uint256 limitPrice;
        bool limitType;
        uint256 slippage;
        uint256 settlementGratuity;
        bool depositedFlag;
        bool settledFlag;
    }

    mapping(uint256 => Attributes) public _orders;
   
    event orderCreated(uint256 _orderID);
    
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance, address _WETH) {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
        nocturnalFinanceAddress = _nocturnalFinance;
        WETH = _WETH;
    }
    
    function createOrder(
        address _poolAddress,
        address _fromTokenAddress,
        address _toTokenAddress,
        uint256 _tokenBalance,
        uint256 _limitPrice,
        uint256 _slippage,
        bool _limitType,
        uint256 _settlementGratuity
    ) external {
        require(msg.sender == nocturnalFinance.orderManagerAddress(), "not OrderManager contract");
        require((_fromTokenAddress == WETH) || (_toTokenAddress == WETH), "pool must contain WETH");
        require(IERC20(_fromTokenAddress).balanceOf(msg.sender) >= _tokenBalance);
        require((_settlementGratuity >= 0) && (_settlementGratuity < 10000));  
        Order nocturnalOrder = new Order("Nocturnal Order", "oNOCT", nocturnalFinanceAddress); 
        orderCounter.increment();
        
        OrderInterface(nocturnalFinance.orderAddress()).mint(msg.sender, orderCounter.current());
       
        // set order URI using NocturnalFinance contract's orderURI()
      	OrderInterface(address(nocturnalOrder))._setTokenURI(orderCounter.current(), nocturnalFinance.orderURI());

        // set order attributes
        _orders[orderCounter.current()] = Attributes({
            orderAddress: address(nocturnalOrder),
            poolAddress: _poolAddress,
            fromTokenAddress: _fromTokenAddress,
            toTokenAddress: _toTokenAddress,
            tokenBalance: _tokenBalance,
            fromTokenValueInETH: 0,
            limitPrice: _limitPrice,
            limitType: _limitType,
            slippage: _slippage, 
            settlementGratuity: _settlementGratuity,
            depositedFlag: false,
            settledFlag: false
        }); 
        
        emit orderCreated(orderCounter.current());
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
    
    function setTokenBalance(uint256 _orderID, uint256 _balance) public {
        require(msg.sender == nocturnalFinance.settleOrderAddress(), "not SettleOrder contract");
        _orders[_orderID].tokenBalance = _balance;
    }
    
    function setFromTokenValueInETH(uint256 _orderID, uint256 _valueInETH) public {
        require(msg.sender == nocturnalFinance.depositOrderAddress(), "not SettleOrder contract");
        _orders[_orderID].fromTokenValueInETH = _valueInETH;
    }
    
    function setDepositedFlag(uint256 _orderID, bool _flag) public {
        require(msg.sender == nocturnalFinance.depositOrderAddress(), "not SettleOrder contract");
        _orders[_orderID].depositedFlag = _flag;
    }
    
    function setSettledFlag(uint256 _orderID, bool _flag) public {
        require(msg.sender == nocturnalFinance.settleOrderAddress(), "not SettleOrder contract");
        _orders[_orderID].settledFlag =  _flag;
    }
    
    function setSlippage(uint256 _orderID, uint256 _slippage) public {
        require(msg.sender == nocturnalFinance.modifyOrderAddress(), "not ModifyOrder contract");
        _orders[_orderID].slippage = _slippage;
    }
    
    function setSettlementGratuity(uint256 _orderID, uint256 _gratuity) public {
        require(msg.sender == nocturnalFinance.modifyOrderAddress(), "not ModifyOrder contract");
        _orders[_orderID].settlementGratuity = _gratuity;
    }  
}
