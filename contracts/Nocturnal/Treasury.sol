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
import {IERC20} from "../shared/interfaces/IERC20.sol";
import {NoctInterface} from "./Interfaces/NoctInterface.sol";

contract Treasury {
    
    using SafeMath for uint256;
    
    mapping(address => uint256) public treasuryBalance;
    
    constructor(address noctAddress) {
    }
    
    function setClaimantBalance(address _claimant, uint _balance) external onlyOwner {
        treasuryBalance[_claimant] = _balance;
    }
    
    function claimTreasuryBalance() external {
        require(treasuryBalance[msg.sender] > 0, "insufficient treasury balance");
        require(NoctInterface(noctAddress).transfer(msg.sender, treasuryBalance[msg.sender]), "transfer failed");
        treasuryBalance[msg.sender] = 0;
    }      
}
