/*                              $$\                                             $$\                                                         
                                $$ |                                            $$ |                                                  
$$$$$$$\   $$$$$$\   $$$$$$$\ $$$$$$\   $$\   $$\  $$$$$$\  $$$$$$$\   $$$$$$\  $$ |     
$$  __$$\ $$  __$$\ $$  _____|\_$$  _|  $$ |  $$ |$$  __$$\ $$  __$$\  \____$$\ $$ |    
$$ |  $$ |$$ /  $$ |$$ /        $$ |    $$ |  $$ |$$ |  \__|$$ |  $$ | $$$$$$$ |$$ |     
$$ |  $$ |$$ |  $$ |$$ |        $$ |$$\ $$ |  $$ |$$ |      $$ |  $$ |$$  __$$ |$$ |     
$$ |  $$ |\$$$$$$  |\$$$$$$$\   \$$$$  |\$$$$$$  |$$ |      $$ |  $$ |\$$$$$$$ |$$ |      
\__|  \__| \______/  \_______|   \____/  \______/ \__|      \__|  \__| \_______|\__|     
*/

pragma solidity ^0.6.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
import "https://github.com/Uniswap/uniswap-v3-periphery/blob/main/contracts/interfaces/IPeripheryPayments.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";

contract NoctStaking {
    using SafeMath for uint256;
    address public tA;

    uint256 public trg = 0;
    mapping(address => uint256) public lrc;
    mapping(address => uint256) public staked;
    
    NocturnalFinanceInterface public nocturnalFinance;
    IPeripheryPayments public payment;

    constructor (address _nocturnalFinance) public {
      nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
      tA = nocturnalFinance.sNoctAddress();
    }

    event Stake(uint256 amount, uint256 total);
    event Withdraw(uint256 amount, uint256 total);

    function totalStaked() public view returns (uint256) {
        ERC20 token = ERC20(tA);
        return token.balanceOf(address(this));
    }

    function stake(uint256 amount) public {
        require(amount > 0, "invalid amount");
        ERC20 token = ERC20(tA);
        require(token.balanceOf(msg.sender) >= amount, "insufficent NOCT balance");
        require(token.transferFrom(msg.sender, address(this), amount), "staking failed");
        if (staked[msg.sender] == 0) {
            lrc[msg.sender] = trg;
        }
        staked[msg.sender] = staked[msg.sender].add(amount);
        emit Stake(amount, totalStaked());
    }

    function withdraw(uint256 amount) public {
        require(staked[msg.sender] >= amount, "invalid amount");
        ERC20 token = ERC20(tA);
        require(token.transfer(msg.sender, amount), "transfer failed");
        staked[msg.sender] = staked[msg.sender].sub(amount);

        uint256 totalBalance = token.balanceOf(address(this));
        emit Withdraw(amount, totalBalance);
    }

    function bRSLC(address acc) public view returns (uint256) {
        return trg.sub(lrc[acc]);
    }

    function pendingETHRewards(address account) public view returns (uint256) {
        uint256 base = bRSLC(account);
        return base.mul(staked[account]).div(totalStaked());
    }

    function claimETHRewards() public {
        require(lrc[msg.sender] <= trg, "no rewards available");
        
        uint256 toSend = pendingETHRewards(msg.sender);
        lrc[msg.sender] = trg;
        // use unwrapWETH9() and transfer to staker
        IPeripheryPayments.unwrapWETH9(toSend, msg.sender);
        //require(msg.sender.send(toSend), "transfer failed");
    }

    //this function has to be present or transfers to the contract fail silently
    fallback () external payable {}
}
