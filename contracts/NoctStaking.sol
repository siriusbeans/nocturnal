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

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@uniswap/v3-periphery/contracts/interfaces/IPeripheryPayments.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";

contract NoctStaking is ERC20 ("Staked Nocturnal Token", "sNOCT") {
    using SafeMath for uint256;

    uint256 public trg;
    mapping(address => uint256) public lrc;
    address WETH;
    
    NocturnalFinanceInterface public nocturnalFinance;
    IPeripheryPayments public payment;

    constructor (address _nocturnalFinance, address _WETH) {
      nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
      trg = 0;
      WETH = _WETH;
    }

    event Stake(uint256 amount, uint256 total);
    event Withdraw(uint256 amount, uint256 total);

    function totalStaked() public view returns (uint256) {
        return IERC20(nocturnalFinance._contract(12)).balanceOf(address(this));
    }

    function stake(uint256 amount) public {
        require(amount > 0, "invalid amount");
        require(IERC20(nocturnalFinance._contract(12)).balanceOf(msg.sender) >= amount, "insufficent NOCT balance");
        require(IERC20(nocturnalFinance._contract(12)).transferFrom(msg.sender, address(this), amount), "staking failed");
        _mint(msg.sender, amount);
        emit Stake(amount, totalStaked());
    }
    
    function autoStake(address _claimantAddress, uint256 amount) public {
        require(msg.sender == nocturnalFinance._contract(9) || msg.sender == nocturnalFinance._contract(10), "address not permitted");
        require(amount > 0, "invalid amount");
        require(IERC20(nocturnalFinance._contract(12)).balanceOf(msg.sender) >= amount, "insufficent NOCT balance");
        require(IERC20(nocturnalFinance._contract(12)).transferFrom(msg.sender, address(this), amount), "staking failed");
        _mint(_claimantAddress, amount);
        emit Stake(amount, totalStaked());
    }

    function withdraw(uint256 amount) public {
        require(balanceOf(msg.sender) >= amount, "invalid amount");
        require(IERC20(nocturnalFinance._contract(12)).transfer(msg.sender, amount), "transfer failed");
        _burn(msg.sender, amount);

        uint256 totalBalance = IERC20(nocturnalFinance._contract(12)).balanceOf(address(this));
        emit Withdraw(amount, totalBalance);
    }

    function bRSLC(address acc) public view returns (uint256) {
        return trg.sub(lrc[acc]);
    }
    
    function pendingETHRewards(address account) public view returns (uint256) {
        uint256 base = bRSLC(account);
        return base.mul(IERC20(address(this)).balanceOf(account)).div(totalStaked());
    }    

    function claimETHRewards() public {
        require(lrc[msg.sender] <= trg, "no rewards available");
        
        uint256 toSend = pendingETHRewards(msg.sender);
        lrc[msg.sender] = trg;
        // use unwrapWETH9() and transfer to staker
        //payment.unwrapWETH9(toSend, msg.sender);
        //require(msg.sender.send(toSend), "transfer failed");
        require(IERC20(WETH).transfer(msg.sender, toSend), "transfer failed");
    }
    
    function updateTRG(uint256 _rewards) public {
        require(msg.sender == nocturnalFinance._contract(6), "not SettleOrderTransfer.sol");
        trg = trg.add(_rewards);
    }

    //this function has to be present or transfers to the contract fail silently
    fallback () external payable {}
}

