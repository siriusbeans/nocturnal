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
import {RewardsInterface} from "./Interfaces/RewardsInterface.sol";

contract DistributeRewards {
    using SafeMath for uint256;
    
    uint256 internal constant bPDivisor = 10000;  // 100th of a bip
    
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance) {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
    }

    function distributeNOCT(uint256 sFTVIE, address orderOwnerAddress) public {
        require(msg.sender == nocturnalFinance.settleOrderAddress(), "not SettleOrder contract");
        
        uint256 totalRewards = RewardsInterface(nocturnalFinance.rewardsAddress()).calcRewards(sFTVIE);
        
        // distribute treasury rewards
        uint256 treasuryRewards = totalRewards.mul(nocturnalFinance.treasuryFactor()).div(bPDivisor);
        RewardsInterface(nocturnalFinance.rewardsAddress()).unclaimedRewards(nocturnalFinance.treasuryAddress()).add(treasuryRewards);
        RewardsInterface(nocturnalFinance.rewardsAddress()).totalRewards().add(treasuryRewards);
        
        totalRewards = totalRewards.sub(treasuryRewards);
    
        // distribute creator rewards
        uint256 creatorRewards = totalRewards.mul(nocturnalFinance.rewardsFactor()).div(bPDivisor);
        RewardsInterface(nocturnalFinance.rewardsAddress()).unclaimedRewards(orderOwnerAddress).add(creatorRewards);
        RewardsInterface(nocturnalFinance.rewardsAddress()).totalRewards().add(creatorRewards);
        
        // distribute settler rewards
        uint256 settlerRewards = totalRewards.sub(creatorRewards);
        RewardsInterface(nocturnalFinance.rewardsAddress()).unclaimedRewards(msg.sender).add(settlerRewards);
        RewardsInterface(nocturnalFinance.rewardsAddress()).totalRewards().add(settlerRewards);
    }
}