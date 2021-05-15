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

interface OrderFactoryInterface {
    function createLimitOrder(
            address _swapPoolAddress, 
            address _swapFromTokenAddress, 
            address _swapToTokenAddress, 
            uint256 _swapFromTokenBalance, 
            uint256 _swapLimitPrice,
            bool _swapAbove,
            uint256 _swapSlippage, 
            uint256 _swapSettlementFee) external returns ();
    function settleLimitOrder(address) external returns ();
    function closeLimitOrder(address) external returns ();
    
    function getOrderID(address) external view returns (uint256);
    function getOrderPoolAddress(address) external view returns (address);
    function getOrderFromTokenAddress(address) external view returns (address);
    function getOrderFromTokenBalance(address) external view returns (uint256);
    function getOrderToTokenAddress(address) external view returns (address);
    function getOrderLimitPrice(address) external view returns (uint256);
    function getOrderLimitType(address) external view returns (bool);
    function getOrderSwapSlippage(address) external view returns (uint256);
    function getOrderSettlementGratuity(address) external view returns (uint256);
    function getOrderCreatorRewards(address) external view returns (uint256);
    function getOrderSettlerRewards(address) external view returns (uint256);
    
    function modifyOrderSwapSlippage(address _orderAddress, uint256 _newSwapSlippage) public returns (uint256) {
    function modifyOrderSettlementGratuity(address _orderAddress, uint256 _newSettlementGratuity) public returns (uint256) {
    
    event orderCreated(uint256 orderID, address orderAddress, uint256 settlementGratuity, uint256 creatorRewards, uint256 settlerRewards);
    event orderSettled(uint256 orderID, address orderAddress, uint256 settlementGratuity, uint256 creatorRewards, uint256 settlerRewards);
    event orderClosed(uint256 orderID, address _orderAddress);
    event orderModified(uint256 orderID, address orderAddress, uint256 settlementGratuity, uint256 creatorRewards, uint256 settlerRewards);
    event platformVolumeUpdate(uint256 volume);
}
