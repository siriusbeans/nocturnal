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

import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {NoctInterface} from "./Interfaces/NoctInterface.sol";

contract Treasury is Ownable {
    using SafeMath for uint256;

    mapping(address => bool) treasuryClaimant; // addresses with treasury allocation
    mapping(address => uint256) treasuryBalance; // current balance considering treasury allocation (need mechanism similar to NoctStaking.sol)
    mapping(address => uint256) treasuryFactor; // percentage of treasury allocated to claimant
    
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance) {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
    }
    
    function transferTreasury(address _recipient) external onlyOwner {
        require(NoctInterface(nocturnalFinance.noctAddress()).transfer(_recipient, NoctInterface(nocturnalFinance.noctAddress()).balanceOf(address(this))), "transfer failed");
    }
    
    function addTreasuryClaimant(address _claimant) external onlyOwner {
        treasuryClaimant[_claimant] == true;
    }
    
    function setClaimantFactor(address _claimant, uint _factorBasisPoints) external onlyOwner {
        treasuryFactor[_claimant] = _factorBasisPoints;
    }
    
    function claimTreasuryRewards() external {
        require(treasuryClaimant[msg.sender] == true, "not a treasury claimant address");
        require(treasuryBalance[msg.sender] > 0, "no treasury rewards balance");
        require(NoctInterface(nocturnalFinance.noctAddress()).transfer(msg.sender, treasuryBalance[msg.sender]), "transfer failed");
    }    
}
