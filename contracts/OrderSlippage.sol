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

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {OracleInterface} from "./Interfaces/OracleInterface.sol";

contract OrderSlippage {
    using SafeMath for uint256;

    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance) {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
    }
    
    function minOut (address _pool, address _token, uint256 _balance, uint24 _slippage) external view returns (uint256) {
        require(msg.sender == nocturnalFinance._contract(4) || msg.sender == nocturnalFinance._contract(6), "caller is not a nocturnal contract");
        uint256 rate;
        if (IUniswapV3Pool(_pool).token0() == _token) {
            rate = OracleInterface(nocturnalFinance._contract(7)).getCurrentPriceReciprocal(_pool);
        } else {
            rate = OracleInterface(nocturnalFinance._contract(7)).getCurrentPrice(_pool);
        }
        return ((_balance).mul(rate).div(10000)).sub(((_balance).mul(rate).div(10000)).mul(uint256(_slippage)));
    }
}
