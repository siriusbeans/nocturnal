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
    address public orderCreatorAddress;
    address public orderSettlerAddress;
    address public orderCloserAddress;
    address public orderModifierAddress;
    address public orderTransferAddress;
    address public noctAddress;
    address public sNoctAddress;
    address public orderAddress;
    address public treasuryAddress;
    uint256 public depositFeeRate;
    uint256 public rewardsRatioFactor;
    uint256 public treasuryFactor;
    string public orderURI;
    
    constructor() {
    }
    
    function initNocturnal( 
            address _oracleAddress, 
            address _rewardsAddress,
            address _orderFactoryAddress,
            address _orderCreatorAddress,
            address _orderSettlerAddress,
            address _orderCloserAddress,
            address _orderModifierAddress,
            address _orderTransferAddress,
            address _orderAddress,
            address _treasuryAddress) external onlyOwner {
		require(_oracleAddress != address(0));
		require(_rewardsAddress != address(0));
		require(_orderFactoryAddress != address(0));
		require(_orderCreatorAddress != address(0));
		require(_orderSettlerAddress != address(0));
		require(_orderCloserAddress != address(0));
		require(_orderModifierAddress != address(0));
		require(_orderTransferAddress != address(0));
		require(_orderAddress != address(0));
		require(_treasuryAddress != address(0));
        oracleAddress = _oracleAddress;
        rewardsAddress = _rewardsAddress;
        orderFactoryAddress = _orderFactoryAddress;
        orderCreatorAddress = _orderCreatorAddress;
        orderSettlerAddress = _orderSettlerAddress;
        orderModifierAddress = _orderModifierAddress;
        orderTransferAddress = _orderTransferAddress;
        orderAddress = _orderAddress;
        treasuryAddress = _treasuryAddress;
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
    
    function setTreasuryFactory(uint256 _tFactorBasisPoints) external onlyOwner {
        treasuryFactor = _tFactorBasisPoints;
    }
    
    function setOrderURI(string memory _orderURI) external onlyOwner {
        orderURI = _orderURI;
    }
    
    function depositRate() external view returns (uint256) {
        return (depositFeeRate);
    }
     
    function rewardsFactor() external view returns (uint256) {
        return (rewardsRatioFactor);
    }
    
    function treasuryRate() external view returns (uint256) {
        return (treasuryFactor);
    }
    
    function getURI() external view returns (string memory) {
        return (orderURI);
    }
}
