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

import "@openzeppelin/contracts/access/Ownable.sol";

contract NocturnalFinance is Ownable {
    
    address public oracleAddress;
    address public rewardsAddress;
    address public orderFactoryAddress;
    address public noctAddress;
    address public sNoctAddress;
    address public orderAddress;
    uint256 public depositFeeRate;
    uint256 public rewardsRatioFactor;
    
    mapping(address => bool) testerAddress;
    
    constructor() public {
    }
    
    function initNocturnal( 
            address _oracleAddress, 
            address _rewardsAddress,
            address _orderFactoryAddress,
            address _orderAddress) external onlyOwner {
		require(_oracleAddress != address(0));
		require(_rewardsAddress != address(0));
		require(_orderFactoryAddress != address(0));
		require(_orderAddress != address(0));
        oracleAddress = _oracleAddress;
        rewardsAddress = _rewardsAddress;
        orderFactoryAddress = _orderFactoryAddress;
    }
    
    function initNoct(address _noctAddress) external onlyOwner {
        require(_noctAddress != address(0));
        noctAddress = _noctAddress;
    }
    
    function initsNoct(address _sNoctAddress) external onlyOwner {
        require(_sNoctAddress != address(0));
        sNoctAddress = _sNoctAddress;
    }
    
    function setDepositRate(uint256 _dRateBasisPoints) external onlyOwner {
        depositFeeRate = _dRateBasisPoints;
    }
    
    function setRewardsFactor(uint256 _rFactorBasisPoints) external onlyOwner {
        rewardsRatioFactor = _rFactorBasisPoints;
    }
    
    function depositRate() external view returns (uint256) {
        return (depositFeeRate);
    }
     
    function rewardsFactor() external view returns (uint256) {
        return (rewardsRatioFactor);
    }
}
