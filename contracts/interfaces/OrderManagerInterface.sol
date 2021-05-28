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

interface OrderManagerInterface {

    function createOrder(address, address, address, uint256, uint256, uint256, bool, uint256) external;
    
    function settleOrder(uint256) external;
    
    function closeOrder(uint256) external;
    
    function getOrderAttributes(uint256) external view 
        returns (address, address, address, address, uint256, uint256, uint256, uint256, bool, uint256, uint256, bool);

    function modifyOrderSlippage(uint256, uint256) external;
    
    function modifyOrderSettlementGratuity(uint256, uint256) external;
}
