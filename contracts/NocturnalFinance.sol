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
import {RewardsInterface} from "./Interfaces/RewardsInterface.sol";
import {TreasuryInterface} from "./Interfaces/TreasuryInterface.sol";

contract NocturnalFinance is Ownable {
    
    address public oracleAddress;
    address public rewardsAddress;
    address public orderManagerAddress;
    address public createOrderAddress;
    address public depositOrderAddress;
    address public settleOrderAddress;
    address public closeOrderAddress;
    address public modifyOrderAddress;
    address public settleOrderTransferAddress;
    address public noctAddress;
    address public sNoctAddress;
    address public orderAddress;
    address public treasuryAddress;
    address public distributeRewardsAddress;
    address public valueInEthAddress;
    uint256 public platformRate;
    uint256 public rewardsRatioFactor;
    uint256 public treasuryFactor;
    string public orderURI;
    
    constructor() {
    }
    
    function initNocturnal( 
            address _oracleAddress, 
            address _rewardsAddress,
            address _orderManagerAddress,
            address _createOrderAddress,
            address _depositOrderAddress,
            address _settleOrderAddress,
            address _closeOrderAddress,
            address _modifyOrderAddress,
            address _settleOrderTransferAddress,
            address _orderAddress,
            address _treasuryAddress,
            address _distributeRewardsAddress,
            address _valueInEthAddress) external onlyOwner {
		require(_oracleAddress != address(0));
		require(_rewardsAddress != address(0));
		require(_orderManagerAddress != address(0));
		require(_createOrderAddress != address(0));
		require(_depositOrderAddress != address(0));
		require(_settleOrderAddress != address(0));
		require(_closeOrderAddress != address(0));
		require(_modifyOrderAddress != address(0));
		require(_settleOrderTransferAddress != address(0));
		require(_orderAddress != address(0));
		require(_treasuryAddress != address(0));
		require(_distributeRewardsAddress != address(0));
		require(_valueInEthAddress != address(0));
        oracleAddress = _oracleAddress;
        rewardsAddress = _rewardsAddress;
        orderManagerAddress = _orderManagerAddress;
        createOrderAddress = _createOrderAddress;
        depositOrderAddress = _depositOrderAddress;
        settleOrderAddress = _settleOrderAddress;
        closeOrderAddress = _closeOrderAddress;
        modifyOrderAddress = _modifyOrderAddress;
        settleOrderTransferAddress = _settleOrderTransferAddress;
        orderAddress = _orderAddress;
        treasuryAddress = _treasuryAddress;
        distributeRewardsAddress = _distributeRewardsAddress;
        valueInEthAddress = _valueInEthAddress;
    }
    
    function initNoct(address _noctAddress) external onlyOwner {
        require(_noctAddress != address(0));
        noctAddress = _noctAddress;
    }
    
    function initsNoct(address _sNoctAddress) external onlyOwner {
        require(_sNoctAddress != address(0));
        sNoctAddress = _sNoctAddress;
    }
    
    function rewardsApproval() external onlyOwner {
        RewardsInterface(rewardsAddress).approveStaking();
    }
    
    function treasuryApproval() external onlyOwner {
        TreasuryInterface(treasuryAddress).approveStaking();
    }
    
    function setPlatformRate(uint256 _pRateBasisPoints) external onlyOwner {
        platformRate = _pRateBasisPoints;
    }
    
    function setRewardsFactor(uint256 _rFactorBasisPoints) external onlyOwner {
        rewardsRatioFactor = _rFactorBasisPoints;
    }
    
    function setTreasuryFactor(uint256 _tFactorBasisPoints) external onlyOwner {
        treasuryFactor = _tFactorBasisPoints;
    }
    
    function setOrderURI(string memory _orderURI) external onlyOwner {
        orderURI = _orderURI;
    }
}
