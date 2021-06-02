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

    function distributeNOCT(uint256 sFTVIE, address orderOwnerAddress, address settlerAddress) public {
        require(msg.sender == nocturnalFinance._contract(3), "not SettleOrder contract");  
        
        uint256 orderRewards = RewardsInterface(nocturnalFinance._contract(9)).calcRewards(sFTVIE);
        RewardsInterface(nocturnalFinance._contract(9)).addTotalRewards(orderRewards);
        
        // distribute treasury rewards
        uint256 treasuryRewards = orderRewards.mul(nocturnalFinance.treasuryFactor()).div(bPDivisor);
        RewardsInterface(nocturnalFinance._contract(9)).addUnclaimedRewards(nocturnalFinance._contract(10), treasuryRewards);
        
        orderRewards = orderRewards.sub(treasuryRewards);
    
        // distribute creator rewards
        uint256 creatorRewards = orderRewards.mul(nocturnalFinance.rewardsRatioFactor()).div(bPDivisor);
        RewardsInterface(nocturnalFinance._contract(9)).addUnclaimedRewards(orderOwnerAddress, creatorRewards);
        
        // distribute settler rewards
        uint256 settlerRewards = orderRewards.sub(creatorRewards);
        RewardsInterface(nocturnalFinance._contract(9)).addUnclaimedRewards(settlerAddress, settlerRewards);
    }
}
