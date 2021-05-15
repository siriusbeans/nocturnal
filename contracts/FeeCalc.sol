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

import "https://github.com/Uniswap/uniswap-v3-core/blob/main/contracts/interfaces/IUniswapV3Pool.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";

contract FeeCalc {
    
    constructor(address _nocturnalFinance) public {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
    }
   
    function getDepositFee() external view returns (uint256) {
        uint256 _fee = nocturnalFinance.setDepositRate();
        return(_fee);
    }
}
