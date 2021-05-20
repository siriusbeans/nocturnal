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
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {NoctInterface} from "./Interfaces/NoctInterface.sol";
import {NoctStakingInterface} from "./Interfaces/NoctStakingInterface.sol";

contract Rewards {
    using SafeMath for uint256;
    
    mapping(address => uint256) public unclaimedRewards;
    
    uint256 public totalRewards;
    uint256 internal constant rewardsRateDivisor = 1e12;

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
    
    function calcRewards(uint256 _valueETH) external view returns (uint256) {
        require(msg.sender == nocturnalFinance.orderSettlerAddress(), "only order settler calls calcRewards");
        uint256 totalSupply = NoctInterface(nocturnalFinance.noctAddress()).totalSupply();
        uint256 supplyDiff = totalSupply.sub(totalRewards);
        uint256 rewardsRate = _valueETH.div(rewardsRateDivisor); // equal to value in ETH / 1000000
        return (rewardsRate.mul(supplyDiff)); 
    }
}
