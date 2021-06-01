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
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {NoctInterface} from "./Interfaces/NoctInterface.sol";
import {NoctStakingInterface} from "./Interfaces/NoctStakingInterface.sol";

contract Rewards {
    using SafeMath for uint256;
    
    mapping(address => uint256) public unclaimedRewards;
    
    uint256 rewardsSupply;
    address nocturnalFinanceAddress;
    uint256 public totalRewards;
    uint256 internal constant rewardsRateDivisor = 1e12;

    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance, uint256 _rewardsSupply) {
        rewardsSupply = _rewardsSupply;
        nocturnalFinanceAddress = _nocturnalFinance;
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
    }
    
    function approveStaking() external {
        require(msg.sender == nocturnalFinanceAddress, "not Nocturnal Finance");
        IERC20(nocturnalFinance._contract(12)).approve(nocturnalFinance._contract(0), rewardsSupply);
    }
    
    function claimRewards(uint256 _amount) public {
        uint256 rBalance = unclaimedRewards[msg.sender];
        require(rBalance >= _amount, "insufficient rewards balance");
        require(NoctInterface(nocturnalFinance._contract(12)).transfer(msg.sender, _amount), "rewards transfer failed");
        unclaimedRewards[msg.sender] = rBalance.sub(_amount);
    }
    
    function stakeRewards(uint256 _amount) public {
        uint256 rBalance = unclaimedRewards[msg.sender];
        require(rBalance >= _amount, "insufficient rewards balance");
        NoctStakingInterface(nocturnalFinance._contract(0)).autoStake(msg.sender, _amount);
        unclaimedRewards[msg.sender] = rBalance.sub(_amount);
    }
    
    function calcRewards(uint256 _valueETH) external view returns (uint256) {
        require(msg.sender == nocturnalFinance._contract(11), "not DistributeRewards.sol");
        uint256 totalSupply = NoctInterface(nocturnalFinance._contract(12)).totalSupply();
        uint256 supplyDiff = totalSupply.sub(totalRewards);
        uint256 rewardsRate = _valueETH.div(rewardsRateDivisor); // equal to value in ETH / 1000000
        return (rewardsRate.mul(supplyDiff)); 
    }
}
