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

contract Oracle {
    using SafeMath for uint256;

    uint256 internal constant multiplicand = 1e18;

    IUniswapV3Pool public pool;
    
    constructor() {
    }
    
    function getCurrentPrice(address _pool) external view returns (uint256) {
        (uint160 sqrtPriceX96,,,,,,) = IUniswapV3Pool(_pool).slot0();
        return uint256(sqrtPriceX96).mul(uint256(sqrtPriceX96)).mul(1e18) >> (96*2);
    }
    
    function getCurrentSqrtPrice(address _pool) external view returns (uint160) {
        (uint160 sqrtPriceX96,,,,,,) = IUniswapV3Pool(_pool).slot0();
        return sqrtPriceX96;
    }
    
    function getPriceReciprocal(uint256 _price) external pure returns (uint256) {
        uint256 reciprocalPrice = multiplicand.mul(multiplicand).div(_price);
        return (reciprocalPrice);
    }
    
    // to be used by front end to reduce a pool address to its token addresses
    // front end should also determine which token (0 or 1) is fromToken
    function getTokens(address _pool) external view returns (address, address) {
        address token0 = IUniswapV3Pool(_pool).token0();
        address token1 = IUniswapV3Pool(_pool).token1();
        return(token0, token1);
    }
    
    
}
