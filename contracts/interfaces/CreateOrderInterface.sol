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

interface CreateOrderInterface {
    
    function createOrder(address, address, address, uint256, uint256, uint256, bool, uint256) external;
        
    function orderAttributes(uint256) external view 
        returns (address, address, address, address, uint256, uint256, uint256, uint256, bool, uint256, uint256, bool);
 
    function setToTokenBalance(uint256, uint256) external;
    function setFromTokenBalance(uint256, uint256) external;
    function setSettledFlag(uint256, bool) external;
    function setSlippage(uint256, uint256) external;
    function setSettlementGratuity(uint256, uint256) external;

    event orderCreated(uint256 _orderID);
}
