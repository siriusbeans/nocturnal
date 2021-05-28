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
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {OracleInterface} from "./Interfaces/OracleInterface.sol";

contract ValueInEth {
    using SafeMath for uint256;
    
    uint256 tokenValueInETH;
    address WETH;
    
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance, address _WETH) {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
        WETH = _WETH;
    }

    function getValueInEth(address _fromTokenAddress, uint256 _fromTokenBalance, address _poolAddress) external returns (uint256) {
        require(msg.sender == nocturnalFinance.createOrderAddress());
        if (_fromTokenAddress == WETH) {
            // set fromTokenBalance value in ETH order attribute
                tokenValueInETH = (_fromTokenBalance);         
        } else {
            // set fromTokenBalance value in ETH order attribute
            if (IUniswapV3Pool(_poolAddress).token0() == _fromTokenAddress) {
                // use reciprocal of current price
                tokenValueInETH = (_fromTokenBalance).mul(OracleInterface(nocturnalFinance.oracleAddress()).getCurrentPriceReciprocal(_poolAddress));
            } else {           
                // use current price    
                tokenValueInETH = (_fromTokenBalance).mul(OracleInterface(nocturnalFinance.oracleAddress()).getCurrentPrice(_poolAddress));
            }
        }
        return (tokenValueInETH);
    }
}
