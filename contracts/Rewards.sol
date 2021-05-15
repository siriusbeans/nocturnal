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

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.1.0/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {NoctInterface} from "./Interfaces/NoctInterface.sol";
import {OrderFactoryInterface} from "./Interfaces/OrderFactoryInterface.sol";

contract Rewards {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    
    uint256 public totalRewards;
    Counter.counters public totalRewards;
    
    mapping(address => uint256) public unclaimedRewards;

    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance) public {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
    }
    
    function claimRewards(uint256 _amount) public {
        require(NoctInterface(nocturnalFinance.noctAddress()).balanceOf(msg.sender) >= _amount, "insufficient unclaimed rewards balance");
        require(NoctInterface(nocturnalFinance.noctAddress()).transfer(msg.sender, _amount), "rewards transfer failed");
    }
    
    function stakeRewards(uint256 _amount) public {
        require(NoctInterace(nocturnalFinance.noctAddress()).balanceOf(msg.sender) >= _amount, "insufficient unclaimed rewards balance");
        require(NoctInterface(nocturnalFinance.noctAddress()).autoStake(), "rewards stake failed");
    }
}
