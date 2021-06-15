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
import {OrderAttributes, AppStorage, LibAppStorage} from "./libraries/LibAppStorage.sol";
import {RewardsInterface} from "./Interfaces/RewardsInterface.sol";
import {OrderInterface} from "./Interfaces/OrderInterface.sol";

contract DistributeRewards {
    AppStorage internal s;

    using SafeMath for uint256;
    
    uint256 internal constant bPDivisor = 10000;  // 100th of a bip
   
    constructor() {
    }

    function distributeNOCT(uint256 _orderID, uint256 sFTVIE, address settlerAddress) external {

        require(msg.sender == s.settleOrderAddress, "not SettleOrder contract");  
        address orderOwnerAddress = OrderInterface(s.orderAddress).ownerOf(_orderID);
        
        uint256 orderRewards = RewardsInterface(s.rewardsAddress).calcRewards(sFTVIE);
        RewardsInterface(s.rewardsAddress).addTotalRewards(orderRewards);
        
        // distribute treasury rewards
        uint256 treasuryRewards = orderRewards.mul(s.treasuryFactor()).div(bPDivisor);
        RewardsInterface(s.rewardsAddress).addUnclaimedRewards(s.treasuryAddress, treasuryRewards);
        
        orderRewards = orderRewards.sub(treasuryRewards);
    
        // distribute creator rewards
        uint256 creatorRewards = orderRewards.mul(s.rewardsRatioFactor()).div(bPDivisor);
        RewardsInterface(s.rewardsAddress).addUnclaimedRewards(orderOwnerAddress, creatorRewards);
        
        // distribute settler rewards
        uint256 settlerRewards = orderRewards.sub(creatorRewards);
        RewardsInterface(s.rewardsAddress).addUnclaimedRewards(settlerAddress, settlerRewards);
    }
}
