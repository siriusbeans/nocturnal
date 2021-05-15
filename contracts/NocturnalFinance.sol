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
    address public orderFactoryAddress;
    address public feeRateAddress;
    address public noctAddress;
    address public sNoctAddress;
    address public orderAddress;
    address public rewardsAddress;
    uint256 public _depositRate;
    uint256 public _rewardsFactor;
    uint256 public _testerRewards;
    
    mapping(address => bool) private testerAddresses;
    
    constructor() public {
    }
    
    function initNocturnal( 
            address _oracleAddress, 
            address _rewardsAddress,
            address _orderFactoryAddress,
            address _orderAddress,
            address _feeRateAddress) external onlyOwner {
		require(_oracleAddress != address(0));
		require(_rewardsAddress != address(0));
		require(_orderFactoryAddress != address(0));
		require(_orderAddress != address(0));
		require(_feeRateAddress != address(0));
        oracleAddress = _oracleAddress;
        rewardsAddress = _rewardsAddress;
        orderFactoryAddress = _orderFactoryAddress;
        feeRateAddress = _feeRateAddress;
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
        _depositRate = _dRateBasisPoints;
    }
    
    function setRewardsFactor(uint256 _rFactorBasisPoints) external onlyOwner {
        _rewardsFactor = _rFactorBasisPoints;
    }
    
    function setTesterAddress(address _testerAddress) external onlyOwner {
        testerAddresses[_testerAddress] == true;
    }
      
    function setTesterRewards(uint256 __testerRewards) external onlyOwner {
        _testerRewards = __testerRewards;
    }
    
    function depositRate() external view returns (uint256) {
        return (_depositRate);
    }
     
    function rewardsFactor() external view returns (uint256) {
        return (_rewardsFactor);
    }
    
    function testerAddress(address _testerAddress) external view returns (bool) {
        return (testerAddresses[_testerAddress]);
    }
    
    function testerRewards() external view returns (uint256) {
        return (_testerRewards);
    }
}
