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
    function orderFactoryAddress() external view returns (address);
    function orderCreatorAddress() external view returns (address);
    function orderSettlerAddress() external view returns (address);
    function orderCloserAddress() external view returns (address);
    function orderModifierAddress() external view returns (address);
    function orderTransferAddress() external view returns (address);
    function orderAddress() external view returns (address);
    function treasuryAddress() external view returns (address);
    function noctAddress() external view returns (address);
    function sNoctAddress() external view returns (address);
    
    function setDepositRate(uint256) external;
    function setTreasuryFactor(uint256) external;
    function setRewardsFactor(uint256) external;
    
    function depositRate() external view returns (uint256);
    function rewardsFactor() external view returns (uint256);
    function treasuryFactor() external view returns (uint256);
    function getURI() external view returns (string memory);
}
