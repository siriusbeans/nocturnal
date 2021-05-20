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

    mapping(address => uint256) treasuryBalance; // current balance considering treasury allocation (need mechanism similar to NoctStaking.sol)
    
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance) {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
    }
    
    function setClaimantBalance(address _claimant, uint _balance) external onlyOwner {
        treasuryBalance[_claimant] = _balance;
    }
    
    function claimTreasuryBalance() external {
        require(treasuryBalance[msg.sender] > 0, "no treasury rewards balance");
        require(NoctInterface(nocturnalFinance.noctAddress()).transfer(msg.sender, treasuryBalance[msg.sender]), "transfer failed");
        treasuryBalance[msg.sender] = 0;
    }    
}
