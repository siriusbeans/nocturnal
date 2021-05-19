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

interface OrderFactoryInterface {
    function createLimitOrder(
            address _swapPoolAddress, 
            address _swapFromTokenAddress, 
            address _swapToTokenAddress, 
            uint256 _swapFromTokenBalance, 
            uint256 _swapLimitPrice,
            uint256 _swapSlippage, 
            bool _swapAbove,
            uint256 _swapSettlementFee) external;
    function settleLimitOrder(address) external;
    function closeLimitOrder(address) external;
    
    function swapOrderID(address) external view returns (uint256);
    function swapPoolAddress(address) external view returns (address);
    function swapFromTokenAddress(address) external view returns (address);
    function swapToTokenAddress(address) external view returns (address);
    function swapFromTokenBalance(address) external view returns (uint256);
    function swapToTokenBalance(address) external view returns (uint256);
    function swapFromTokenValueInETH(address) external view returns (uint256);
    function swapLimitPrice(address) external view returns (uint256);
    function swapAbove(address) external view returns (bool);
    function swapSlippage(address) external view returns (uint256);
    function swapSettlementGratuity(address) external view returns (uint256);
    function swapSettledFlag(address) external view returns (bool);
    
    function setOrderID(address, uint256) external;
    function setOrderPoolAddress(address, address) external;
    function setOrderFromTokenAddress(address, address) external;
    function setOrderFromTokenBalance(address, uint256) external;
    function setOrderToTokenAddress(address, address) external;
    function setOrderToTokenBalance(address, uint256) external;
    function setOrderFromTokenValueInETH(address, uint256) external;
    function setOrderLimitPrice(address, uint256) external;
    function setOrderLimitType(address, bool) external;
    function setOrderSwapSlippage(address, uint256) external;
    function setOrderSettlementGratuity(address, uint256) external;
    function setOrderSettledFlag(address, bool) external;
    
    function getOrderID(address) external view returns (uint256);
    function getOrderPoolAddress(address) external view returns (address);
    function getOrderFromTokenAddress(address) external view returns (address);
    function getOrderFromTokenBalance(address) external view returns (uint256);
    function getOrderToTokenAddress(address) external view returns (address);
    function getOrderLimitPrice(address) external view returns (uint256);
    function getOrderLimitType(address) external view returns (bool);
    function getOrderSwapSlippage(address) external view returns (uint256);
    function getOrderSettlementGratuity(address) external view returns (uint256);
    function getOrderSettledFlag(address) external view returns (bool);
    
    function modifyOrderSwapSlippage(address _orderAddress, uint256 _newSwapSlippage) external;
    function modifyOrderSettlementGratuity(address _orderAddress, uint256 _newSettlementGratuity) external;
    
    event orderCreated(uint256 orderID, address orderAddress, uint256 settlementGratuity);
    event orderSettled(uint256 orderID, address orderAddress, uint256 settlementGratuity);
    event orderClosed(uint256 orderID, address _orderAddress);
    event orderModified(uint256 orderID, address orderAddress, uint256 settlementGratuity);
    event platformVolumeUpdate(uint256 volume);
}
