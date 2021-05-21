pragma solidity ^0.8.0;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockPool is Ownable {
    using SafeMath for uint256;
    
    uint256 public immutable MAXINT = type(uint256).max;
    address internal constant UniswapV3SwapRouter = 0xbBca0fFBFE60F60071630A8c80bb6253dC9D6023;
    address internal constant UniswapV3Factory = 0x7046f9311663DB8B7cf218BC7B6F3f17B0Ea1047;
    uint256 internal constant bPDivisor = 1000;  // 100th of a bip
    uint24 internal constant fee = 100; // 1%
    uint256 internal constant multiplicand = 1e18;
    
    address internal token0;
    address internal token1;
    
    IUniswapV3Factory public factory;
    ISwapRouter public swapRouter;
    IUniswapV3Pool public pool;
    
    constructor(address _token0, address _token1) {
        token0 = _token0;
        token1 = _token1;
        swapRouter = ISwapRouter(UniswapV3SwapRouter);
        factory = IUniswapV3Factory(UniswapV3Factory);
    }
    
    function createPool(uint24 _fee) public onlyOwner {
        address poolAddress = factory.createPool(token0, token1, _fee);
    }
    
    function getPool(address _token0, address _token1, uint24 _fee) external view returns (address) {
        address poolAddress = factory.getPool(_token0, _token1, _fee);
        return(poolAddress);
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
    }
}    
