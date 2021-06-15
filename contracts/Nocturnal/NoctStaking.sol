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

import {ERC20} from "../shared/libraries/ERC20.sol";
import {IERC20} from "../shared/interfaces/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {AppStorage} from "./libraries/LibAppStorage.sol";
//import "@uniswap/v3-periphery/contracts/interfaces/IPeripheryPayments.sol";

contract NoctStaking is ERC20 ("Staked Nocturnal Token", "sNOCT") {
    AppStorage internal s;

    using SafeMath for uint256;

    uint256 public trg;
    mapping(address => uint256) public lrc;
    address WETH;
    
    //IPeripheryPayments public payment;

    constructor (address diamondAddress, address noctAddress, address _WETH) {
      WETH = _WETH;
    }

    event Stake(uint256 amount, uint256 total);
    event Withdraw(uint256 amount, uint256 total);

    function totalStaked() public view returns (uint256) {
        return IERC20(noctAddress).balanceOf(address(this));
    }

    function stake(uint256 amount) public {

        require(amount > 0, "invalid amount");
        require(IERC20(noctAddress).balanceOf(msg.sender) >= amount, "insufficent NOCT balance");
        require(IERC20(noctAddress).transferFrom(msg.sender, address(this), amount), "staking failed");
        _mint(msg.sender, amount);
        emit Stake(amount, totalStaked());
    }

    function withdraw(uint256 amount) public {

        require(balanceOf(msg.sender) >= amount, "invalid amount");
        require(IERC20(noctAddress).transfer(msg.sender, amount), "transfer failed");
        _burn(msg.sender, amount);

        uint256 totalBalance = IERC20(noctAddress).balanceOf(address(this));
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
    
    function updateTRG(uint256 _rewards) internal {
        //require(msg.sender == s.settleOrderFacetAddress, "not settleOrderFacet");
        require(msg.sender == diamondAddress, "not nocturnal diamond");
        trg = trg.add(_rewards);
    }

    //this function has to be present or transfers to the contract fail silently
    //fallback () external payable {}
}

