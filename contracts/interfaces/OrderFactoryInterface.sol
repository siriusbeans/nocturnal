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
            bool _swapAbove,
            uint256 _swapSlippage, 
            uint256 _swapSettlementFee) external;
    function settleLimitOrder(address) external;
    function closeLimitOrder(address) external;
    
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
    
    function modifyOrderSwapSlippage(address _orderAddress, uint256 _newSwapSlippage) external returns (uint256);
    function modifyOrderSettlementGratuity(address _orderAddress, uint256 _newSettlementGratuity) external returns (uint256);
    
    event orderCreated(uint256 orderID, address orderAddress, uint256 settlementGratuity);
    event orderSettled(uint256 orderID, address orderAddress, uint256 settlementGratuity);
    event orderClosed(uint256 orderID, address _orderAddress);
    event orderModified(uint256 orderID, address orderAddress, uint256 settlementGratuity);
    event platformVolumeUpdate(uint256 volume);
}
