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
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AppStorage} from "./libraries/LibAppStorage.sol";
import {NoctInterface} from "./Interfaces/NoctInterface.sol";

contract Rewards {
    AppStorage internal s;

    using SafeMath for uint256;
    
    mapping(address => uint256) public unclaimedRewards;
    
    uint256 totalSupply;
    address private noctAddress;
    uint256 public totalRewards;
    uint256 internal constant rewardsRateDivisor = 1e12;
    uint256 internal constant multiplicand = 1e18;

    
    constructor(address _noctAddress, uint256 _rewardsSupply, uint256 _initialSupply) {
        noctAddress = _noctAddress;
        totalRewards = _initialSupply;
        totalSupply = _rewardsSupply.add(_initialSupply);
    }
    
    function claimRewards(uint256 _amount) public {
        uint256 rBalance = unclaimedRewards[msg.sender];
        require(rBalance >= _amount, "insufficient rewards balance");
        require(NoctInterface(noctAddress).transfer(msg.sender, _amount), "rewards transfer failed");
        unclaimedRewards[msg.sender] = rBalance.sub(_amount);
    }
    
    function calcRewards(uint256 _valueETH) external view returns (uint256) {
        //require(msg.sender == s.distributeRewardsFacetAddress, "not DistributeRewards.sol"); 
        require(msg.sender == s.diamondAddress, "not nocturnal diamond"); 
        uint256 supplyDiff = totalSupply.sub(totalRewards);
        return _valueETH.mul(supplyDiff).div(rewardsRateDivisor.mul(multiplicand)); 
    }
    
    function addUnclaimedRewards(address _claimant, uint256 _rewards) external {
        //require(msg.sender == s.distributeRewardsFacetAddress, "not DistributeRewards.sol");
        require(msg.sender == s.diamondAddress, "not nocturnal diamond");
        unclaimedRewards[_claimant] = (unclaimedRewards[_claimant]).add(_rewards);
    }
    
    function addTotalRewards(uint256 _rewards) external {
        //require(msg.sender == s.distributeRewardsFacetAddress, "not DistributeRewards.sol");
        require(msg.sender == s.diamondAddress, "not nocturnal diamond");
        totalRewards = totalRewards.add(_rewards);
    }
}
