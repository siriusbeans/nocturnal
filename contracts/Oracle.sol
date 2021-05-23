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
    address internal constant UniswapV3Factory = 0x7046f9311663DB8B7cf218BC7B6F3f17B0Ea1047;

    IUniswapV3Pool public pool;
    
    constructor() {
    }
    
    function getCurrentPrice(address _pool) external view returns (uint256) {
        (uint160 sqrtPriceX96,,,,,,) = IUniswapV3Pool(_pool).slot0();
        return uint256(sqrtPriceX96).mul(uint256(sqrtPriceX96)).mul(1e18) >> (96*2);
    }
    
    function getCurrentPriceReciprocal(address _pool) external view returns (uint256) {
        (uint160 sqrtPriceX96,,,,,,) = IUniswapV3Pool(_pool).slot0();
        uint256 _price = uint256(sqrtPriceX96).mul(uint256(sqrtPriceX96)).mul(1e18) >> (96*2);
        return (multiplicand.mul(multiplicand).div(_price));
    }
    
    function getTokens(address _pool) external view returns (address, address) {
        address token0 = IUniswapV3Pool(_pool).token0();
        address token1 = IUniswapV3Pool(_pool).token1();
        return(token0, token1);
    }
    
    function isV3(address _pool) external view returns (bool) {
        address factory = IUniswapV3Pool(_pool).factory(); 
        if (factory == UniswapV3Factory) {
            return (true);
        } else {
            return (false);
        }
    }
}
