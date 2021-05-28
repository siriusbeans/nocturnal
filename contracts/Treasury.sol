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

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {NoctInterface} from "./Interfaces/NoctInterface.sol";
import {NoctStakingInterface} from "./Interfaces/NoctStakingInterface.sol";

contract Treasury is Ownable {
    using SafeMath for uint256;

    uint256 rewardsSupply;
    uint256 initialSupply;
    address nocturnalFinanceAddress;
    
    mapping(address => uint256) treasuryBalance;
    
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance, uint256 _rewardsSupply, uint256 _initialSupply) {
        rewardsSupply = _rewardsSupply;
        initialSupply = _initialSupply;
        nocturnalFinanceAddress = _nocturnalFinance;
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
    }
    
    function approveStaking() external {
        require(msg.sender == nocturnalFinanceAddress, "not Nocturnal Finance");
        IERC20(nocturnalFinance.noctAddress()).approve(nocturnalFinance.sNoctAddress(), rewardsSupply.add(initialSupply));
    }
    
    function setClaimantBalance(address _claimant, uint _balance) external onlyOwner {
        treasuryBalance[_claimant] = _balance;
    }
    
    function claimTreasuryBalance() external {
        require(treasuryBalance[msg.sender] > 0, "insufficient treasury balance");
        require(NoctInterface(nocturnalFinance.noctAddress()).transfer(msg.sender, treasuryBalance[msg.sender]), "transfer failed");
        treasuryBalance[msg.sender] = 0;
    }    
    
    function stakeTreasuryBalance() external {
        require(treasuryBalance[msg.sender] > 0, "insufficient treasury balance");
        NoctStakingInterface(nocturnalFinance.sNoctAddress()).autoStake(msg.sender, treasuryBalance[msg.sender]);
        treasuryBalance[msg.sender] = 0;
    }   
}
