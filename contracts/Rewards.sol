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
import "@openzeppelin/contracts/utils/Counters.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {NoctInterface} from "./Interfaces/NoctInterface.sol";
import {NoctStakingInterface} from "./Interfaces/NoctStakingInterface.sol";

contract Rewards {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    
    uint256 public totalRewards;
    
    mapping(address => uint256) public unclaimedRewards;

    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance) {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
    }
    
    function claimRewards(uint256 _amount) public {
        require(NoctInterface(nocturnalFinance.noctAddress()).balanceOf(msg.sender) >= _amount, "insufficient unclaimed rewards balance");
        require(NoctInterface(nocturnalFinance.noctAddress()).transfer(msg.sender, _amount), "rewards transfer failed");
        uint256 rBalance = unclaimedRewards[msg.sender];
        unclaimedRewards[msg.sender] = rBalance.sub(_amount);
    }
    
    function stakeRewards(uint256 _amount) public {
        require(NoctInterface(nocturnalFinance.noctAddress()).balanceOf(msg.sender) >= _amount, "insufficient unclaimed rewards balance");
        NoctStakingInterface(nocturnalFinance.sNoctAddress()).autoStake(msg.sender, _amount);
        uint256 rBalance = unclaimedRewards[msg.sender];
        unclaimedRewards[msg.sender] = rBalance.sub(_amount);
    }
}
