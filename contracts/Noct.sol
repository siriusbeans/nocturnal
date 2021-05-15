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
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";

contract Noct is ERC20 ("Nocturnal Token", "NOCT") {
    using SafeMath for uint256;

    NocturnalFinanceInterface public nocturnalFinance;
   
    constructor (address _nocturnalFinance) public {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
        address dev0Address = ;
        address dev1Address = ;
    }
    
    mintTesterRewards() external {
        require(nocturnalFinance.testerAddress[msg.sender] == true, "not tester address");
        uint256 rewards = testerRewards[msg.sender];
        _mint(msg.sender, rewards * 10 ** uint256(decimals()));
    }
    
    mintRewards(uint256 _amount, address _recipient) external {
        require(msg.sender == nocturnalFinance.rewardsCalcAddress(), "only rewards calc contract address can mint more NOCT");
        _mint(_recipient, _amount * 10 ** uint256(decimals()));
    }
}
