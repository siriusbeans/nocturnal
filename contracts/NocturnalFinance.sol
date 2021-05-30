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
    
    mapping (uint256 => address) public _contract;
    
    // 0: sNoctAddress;
    // 1: createOrderAddress;
    // 2: depositOrderAddress;
    // 3: settleOrderAddress;
    // 4: closeOrderAddress;
    // 5: modifyOrderAddress;
    // 6: settleOrderTransferAddress;
    // 7: oracleAddress;
    // 8: orderAddress;
    // 9: rewardsAddress;
    // 10: treasuryAddress;
    // 11: distributeRewardsAddress;
    // 12: noctAddress;
    // 13: orderSlippageAddress;

    uint256 public platformRate;
    uint256 public rewardsRatioFactor;
    uint256 public treasuryFactor;
    string public orderURI;
    
    constructor() {
    }
    
    function initNocturnal(uint256 _index, address _address) external onlyOwner {
		_contract[_index] = _address;
    }
    
    function rewardsApproval() external onlyOwner {
        RewardsInterface(_contract[9]).approveStaking();
    }
    
    function treasuryApproval() external onlyOwner {
        TreasuryInterface(_contract[10]).approveStaking();
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
