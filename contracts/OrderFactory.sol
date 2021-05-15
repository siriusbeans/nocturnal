/*                              $$\                                             $$\                                                         
                                $$ |                                            $$ |                                                  
$$$$$$$\   $$$$$$\   $$$$$$$\ $$$$$$\   $$\   $$\  $$$$$$\  $$$$$$$\   $$$$$$\  $$ |     
$$  __$$\ $$  __$$\ $$  _____|\_$$  _|  $$ |  $$ |$$  __$$\ $$  __$$\  \____$$\ $$ |    
$$ |  $$ |$$ /  $$ |$$ /        $$ |    $$ |  $$ |$$ |  \__|$$ |  $$ | $$$$$$$ |$$ |     
$$ |  $$ |$$ |  $$ |$$ |        $$ |$$\ $$ |  $$ |$$ |      $$ |  $$ |$$  __$$ |$$ |     
$$ |  $$ |\$$$$$$  |\$$$$$$$\   \$$$$  |\$$$$$$  |$$ |      $$ |  $$ |\$$$$$$$ |$$ |      
\__|  \__| \______/  \_______|   \____/  \______/ \__|      \__|  \__| \_______|\__|     
*/

pragma solidity ^0.6.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/Uniswap/uniswap-v3-core/blob/main/contracts/interfaces/IUniswapV3Pool.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {NoctInterface} from "./Interfaces/NoctInterface.sol";
import {OracleInterface} from "./Interfaces/OracleInterface.sol";
import {OrderInterface} from "./Interfaces/OrderInteface.sol";

contract OrderFactory {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    
    uint256 public orderCounter;
    uint256 public platformVolume;
    Counter.counters public orderCounter;
    Counter.counters public platformVolume;
    
    mapping(address => uint256) swapOrderID;
    mapping(address => address) swapPoolAddress;
    mapping(address => address) swapFromTokenAddress;
    mapping(address => address) swapToTokenAddress;
    mapping(address => uint256) swapFromTokenBalance;
    mapping(address => uint256) swapFromTokenValueInETH;
    mapping(address => uint256) swapToTokenLimitPrice;
    mapping(address => bool) swapAbove;
    mapping(address => uint256) swapSlippage;
    mapping(address => uint256) swapSettlementGratuity;
    mapping(address => uint256) swapCreatorRewards;
    mapping(address => uint256) swapSettlerRewards;
    
    // may include all attributes in events
    // someone may want to analyze trade data in future
    event orderCreated(uint256 _orderID, address _orderAddress, uint256 _settlementGratuity, uint256 _creatorRewards, uint256 _settlerRewards);
    event orderSettled(uint256 _orderID, address _orderAddress, uint256 _settlementGratuity, uint256 _creatorRewards, uint256 _settlerRewards);
    event orderClosed(uint256 _orderID, address _orderAddress);
    event orderModified(uint256 _orderID, address _orderAddress, uint256 _settlementGratuity, uint256 _creatorRewards, uint256 _settlerRewards);
    event platformVolumeUpdate(uint256 _volume);
    
    NocturnalFinanceInterface public nocturnalFinance;
    IUniswapV3Pool public pool;
    
    constructor(address _nocturnalFinance) public {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
        uint256 internal constant bPDivisor = 1000;  // 100th of a bip
        address internal constant WETH = 0xd0a1e359811322d97991e03f863a0c30c2cf029c; // Kovan, Rinkeby?
    }
    
    function createLimitOrder(
            address _swapPoolAddress, 
            address _swapFromTokenAddress, 
            address _swapToTokenAddress, 
            uint256 _swapFromTokenBalance, 
            uint256 _swapLimitPrice,
            bool _swapAbove,
            uint256 _swapSlippage, 
            uint256 _swapSettlementGratuity) public {
        require((_swapFromTokenAddress == WETH) || (_swapToTokenAddress == WETH), "pool must contain WETH");
        require(ERC20(_swapFromTokenAddress).balanceOf(msg.sender) >= _swapFromTokenBalance )
        uint256 dRateBasisPoints = nocturnalFinance.depositRate();
        require((_swapSettlementGratuity >= 0) && (_swapSettlementGratuity < dRateBasisPoints.mul(100).div(bPDivisor)));
        Order nocturnalOrder = new Order ("Nocturnal Order", "oNOCT"); 
        orderCounter.increment();
        uint256 orderID = orderCounter.current();
        address orderAddress = address(nocturnalOrder);
        
        swapOrderID[orderAddress] = orderID
        swapPoolAddress[orderAddress] = _swapPoolAddress;
        swapFromTokenAddress[orderAddress] = _swapFromTokenAddress;
        swapToTokenAddress[orderAddress] = _swapToTokenAddress;
        swapFromTokenBalance[orderAddress] = _swapFromTokenBalance;
        swapLimitPrice[orderAddress] = _swapLimitPrice;
        swapAbove[orderAddress] = _swapAbove;
        swapSlippage[orderAddress] = _swapSlippage;
        swapSettlementGratuity[orderAddress] = _swapSettlementGratuity;

        OrderInterface(nocturnalFinance.orderAddress())._mint(msg.sender, orderID);
        
        pool = IUniswapV3Pool(_swapPoolAddress);        
        bool fromToken0;
        if (pool.token0 == _swapFromTokenAddress) {
            fromToken0 = true;
        } else {
            fromToken0 = false;    
        }
        
        // Process:
        
        // 1)  Calculate dFee
        uint256 dFee = _swapFromTokenBalance.mul(dRateBasisPoints).div(bPDivisor);

        // 2)  If fromToken is WETH, transfer dFee WETH to Staking.sol then Transfer fromTokenBalance-dFee fromToken to order
        if ((_swapFromTokenAddress == WETH) {
            require(ERC20(_swapFromTokenAddress).transferFrom(msg.sender, nocturnalFinance.sNoctAddress(), dFee), "creator to stakers dFee transfer failed");
            require(ERC20(_swapFromTokenAddress).transferFrom(msg.sender, orderAddress, _swapFromTokenBalance.min(dFee)), "creator to order balance transfer failed");
            
            // get fromTokenBalance value in ETH for tracking platform volume
            if (fromToken0 == true) {
                // interpret price tick data accurately
                // this is not correct
                swapFromTokenValueInETH[orderAddress] = OracleInterface(nocturnalFinance.oracleAddress()).getCurrentPrice(_swapPoolAddress);;
            } else {
                // interpret price tick data accurately
                // this is not correct
                swapFromTokenValueInETH[orderAddress] = OracleInterface(nocturnalFinance.oracleAddress()).getCurrentPrice(_swapPoolAddress);;
            }
            
                 
        // 3)  If toToken is WETH, swap dFee for WETH and send it to Staking.sol then Transfer fromTokenBalance-dFee fromToken to order
        } else if ((_swapToTokenAddress == WETH) ) {
            OrderInterface(nocturnalFinance.orderAddress()).orderSwap(poolAddress, nocturnalFinance.sNoctAddress(), fromToken0, dFee, 0);
            require(ERC20(_swapFromTokenAddress).transferFrom(msg.sender, orderAddress, _swapFromTokenBalance.min(dFee)), "creator to order balance transfer failed");
            
            // get fromTokenBalance value in ETH for tracking platform volume
            if (fromToken0 == true) {
                // interpret price tick data accurately
                // this is not correct
                swapFromTokenValueInETH[orderAddress] = OracleInterface(nocturnalFinance.oracleAddress()).getCurrentPrice(_swapPoolAddress);;
            } else {
                // interpret price tick data accurately
                // this is not correct
                swapFromTokenValueInETH[orderAddress] = OracleInterface(nocturnalFinance.oracleAddress()).getCurrentPrice(_swapPoolAddress);;
            }
        }
        
        // update Order fromTokenBalance attribute for settlement
        swapFromTokenBalance[orderAddress] = _swapFromTokenBalance.min(dFee);
        
        // emit events
        emit orderCreated(orderID, orderAddress, _swapSettlementGratuity, creatorRewards, settlerRewards);
        emit rewardsPending(pendingRewards);
        emit rewardsTotal(totalRewards);
    }
    
    function settleLimitOrder(address _address) public {
        bool above = swapAbove[_address];
        uint256 limitPrice = swapLimitPrice[_address];
        address fromTokenAddress = swapFromTokenAddress[_address];
        address poolAddress = swapPoolAddress[_address];
        uint256 currentPrice;
        pool = IUniswapV3Pool(poolAddress);
        
        //========================================================//
        
        // oracle returns a tick accum value
        // the value of the limit returned by front end may 
        // need to be a function of token0 (fromToken or toToken?)
        if (pool.token0 == fromTokenAddress) {
            // currentPrice = ???
            currentPrice = OracleInterface(nocturnalFinance.oracleAddress()).getCurrentPrice(_address);
        } else {
            // currentPrice = ???
            currentPrice = OracleInterface(nocturnalFinance.oracleAddress()).getCurrentPrice(_address);
        }
        
        if (above == true) {
            require(currentPrice >= limitPrice, "limit not met");
        } else if (above == false) {
            require(currentPrice <= limitPrice, "limit not met");
        }
        
        //========================================================//

        uint256 orderID = swapOrderID[_address];      
        address fromTokenAddress = swapFromTokenAddress[_address];
        address toTokenAddress = swapToTokenAddress[_address];
        uint256 fromTokenBalance = swapFromTokenBalance[_address];
        uint256 slippage = swapSlippage[_address];
        uint256 settlementGratuity = swapSettlementGratuity[_address];
        uint256 creatorRewards = swapCreatorRewards[_address];
        uint256 settlerRewards = swapSettlerRewards[_address];

        // Process:
        
        // 1)  Calculate gratuity
        uint256 gratuity = _swapFromTokenBalance.mul(settlementGratuity).div(bPDivisor);
        
        bool fromToken0;
        if (pool.token0 == _swapFromTokenAddress) {
            fromToken0 = true;
        } else {
            fromToken0 = false;
        }
        
        // 2)  If fromToken is WETH, deduct gratuity from WETH and send to settler before performing the swap then send remainder to creator
        if (_swapFromTokenAddress == WETH) {
            OrderInterface(nocturnalFinance.orderAddress()).orderTransfer(ERC20(_swapFromTokenAddress), msg.sender, gratuity);            
            OrderInterface(nocturnalFinance.orderAddress()).orderSwap(poolAddress, OrderInterface(nocturnalFinance.orderAddress()).ownerOf(orderID), fromToken0, _swapFromTokenBalance.min(gratuity), 0); // zero here may create vulnerability research needed
                 
        // 3)  If toToken is WETH, perform the swap and then deduct gratuity from WETH and send to settler then send remainder to creator
        } else if (_swapToTokenAddress == WETH) {
            OrderInterface(nocturnalFinance.orderAddress()).orderSwap(poolAddress, msg.sender, fromToken0, gratuity, 0);  // zero here may create vulnerability research needed
            OrderInterface(nocturnalFinance.orderAddress()).orderSwap(poolAddress, ownerOf(orderID), fromToken0, _swapFromTokenBalance.min(gratuity), 0);     // zero here may create vulnerability research needed
        }
                
        // 4)  Distribute the NOCT rewards to the settler and the creator
        // creator gets 82% of amount of NOCT equal to swapFromTokenValueInETH
        // settler gets 12% of amount of NOCT equal to swapFromTokenValueInETH
        // devs get 8% of amount of NOCT equal to swapFromTokenValueInETH (auto-staked)


        // increment platform volume tracker counter
        platformVolume.increment(swapFromTokenValueInETH[orderAddress]);
        
        
        // 5)  burn order
        OrderInterface(nocturnalFinance.orderAddress()).burn(orderID);  
        
        // 6) emit events
        emit orderSettled(orderID, orderAddress, settlementGratuity, creatorRewards, settlerRewards);
        emit platformVolumeUpdate(platformVolume);
    }
    
    function closeLimitOrder(address _address) public {
        uint256 orderID = swapOrderID[_address];
        require(OrderInterface(nocturnalFinance.orderAddress()).ownerOf(orderID) == msg.sender, "only order owner can close an order early");
        address fromTokenAddress = swapFromTokenAddress[_address];
        uint256 creatorRewards = swapCreatorRewards[_address];
        uint256 settlerRewards = swapSettlerRewards[_address];        

        // transfer fromTokenBalance from order to msg.sender address
        require(ERC20(_swapFromTokenAddress).transferFrom(_address, msg.sender, _swapFromTokenBalance), "order to creator balance transfer failed");
        
        // burn order
        OrderInterface(nocturnalFinance.orderAddress()).burn(orderID);  //  
        
        // emit events
        emit orderClosed(orderID, _address);
        emit rewardsPending(pendingRewards);
        emit rewardsTotal(totalRewards);
    }

    function getOrderID(address _orderAddress) public view returns (uint256) {
        return swapOrderID[_address];
    }
    
    function getOrderPoolAddress(address _orderAddress) public view returns (address) {
        return swapPoolAddress[_address];
    }
    
    function getOrderFromTokenAddress(address _orderAddress) public view returns (address) {
        return swapFromTokenAddress[_address];
    }
    
    function getOrderFromTokenBalance(address _orderAddress) public view returns (uint256) {
        return swapFromTokenBalance[_address];
    }
    
    function getOrderToTokenAddress(address _orderAddress) public view returns (address) {
        return swapToTokenAddress[_address];
    }
    
    function getOrderLimitPrice(address _orderAddress) public view returns (uint256) {
        return swapToTokenLimitPrice[_address];
    }
    
    function getOrderLimitType(address _orderAddress) public view returns (bool) {
        return swapAbove[_address];
    }
    
    function getOrderSwapSlippage(address _orderAddress) public view returns (uint256) {
        return swapSlippage[_address];
    }
    
    function getOrderSettlementGratuity(address _orderAddress) public view returns (uint256) {
        return swapSettlementGratuity[_address];
    }
    
    function getOrderCreatorRewards(address _orderAddress) public view returns (uint256) {
        return swapCreatorRewards[_address];
    }
    
    function getOrderSettlerRewards(address _orderAddress) public view returns (uint256) {
        return swapSettlerRewards[_address];
    }
    
    function modifyOrderSwapSlippage(address _orderAddress, uint256 _newSwapSlippage) public returns (uint256) {
        uint256 orderID = swapOrderID[_orderAddress];
        require(OrderInterface(nocturnalFinance.orderAddress()).ownerOf(orderID) == msg.sender, "only owner can modify an existing order");
        swapSlippage[_orderAddress] = _newSwapSlippage;
        
        uint256 settlementGratuity = swapSettlementGratuity[_orderAddress];
        uint256 creatorRewards = swapCreatorRewards[_orderAddress];
        uint256 settlerRewards = swapSettlerRewards[_orderAddress];
        
        emit orderModified(orderID, _orderAddress, settlementGratuity, creatorRewards, settlerRewards);      
    }
    
    function modifyOrderSettlementGratuity(address _orderAddress, uint256 _newSettlementGratuity) public returns (uint256) {
        uint256 orderID = swapOrderID[_orderAddress];
        require(OrderInterface(nocturnalFinance.orderAddress()).ownerOf(orderID) == msg.sender, "only owner can modify an existing order");
        swapSettlementGratuity[_orderAddress] = _newSettlementGratuity;
        
        uint256 settlementGratuity = swapSettlementGratuity[_orderAddress];
        uint256 creatorRewards = swapCreatorRewards[_orderAddress];
        uint256 settlerRewards = swapSettlerRewards[_orderAddress];
        
        emit orderModified(orderID, _orderAddress, _newSettlementGratuity, creatorRewards, settlerRewards);      
    }
}
