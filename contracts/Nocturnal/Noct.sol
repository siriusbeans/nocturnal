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
import "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "../shared/libraries/ERC20.sol";

contract Noct is ERC20 ("Nocturnal Token", "NOCT") {

    using SafeMath for uint256;
    
    bool public initialMintFlag;
   
    constructor() {
    }
    
    function initialMint(address rewardsAddress, address treasuryAddress, uint256 _rewardsSupply, uint256 _initialSupply) external onlyOwner {
        require(initialMintFlag == false, "already minted");
        _mint(rewardsAddress, _rewardsSupply);
        _mint(treasuryAddress, _initialSupply);
        initialMintFlag = true;
    }
}
