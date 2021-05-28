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

interface NocturnalFinanceInterface {
    function oracleAddress() external view returns (address);
    function rewardsAddress() external view returns (address);
    function orderManagerAddress() external view returns (address);
    function createOrderAddress() external view returns (address);
    function settleOrderAddress() external view returns (address);
    function closeOrderAddress() external view returns (address);
    function modifyOrderAddress() external view returns (address);
    function settleOrderTransferAddress() external view returns (address);
    function noctAddress() external view returns (address);
    function sNoctAddress() external view returns (address);
    function orderAddress() external view returns (address);
    function treasuryAddress() external view returns (address);
    function distributeRewardsAddress() external view returns (address);
    function valueInEthAddress() external view returns (address);
    
    function platformRate() external view returns (uint256);
    function rewardsFactor() external view returns (uint256);
    function treasuryFactor() external view returns (uint256);
    function orderURI() external view returns (string memory);
}
