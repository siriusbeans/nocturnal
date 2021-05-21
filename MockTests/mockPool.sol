pragma solidity ^0.8.0;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3MintCallback.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockPool is Ownable {
    using SafeMath for uint256;
    
    address internal constant UniswapV3SwapRouter = 0xbBca0fFBFE60F60071630A8c80bb6253dC9D6023;
    address internal constant UniswapV3Factory = 0x7046f9311663DB8B7cf218BC7B6F3f17B0Ea1047;
    uint256 internal constant multiplicand = 1e18;
    int24 internal constant MIN_TICK = -887272;
    int24 internal constant MAX_TICK = -MIN_TICK;
    
    IUniswapV3Factory public factory;
    ISwapRouter public swapRouter;
    IUniswapV3Pool public pool;
    
    constructor() {
        swapRouter = ISwapRouter(UniswapV3SwapRouter);
        factory = IUniswapV3Factory(UniswapV3Factory);
    }
    
    function createPool(address _token0, address _token1, uint24 _fee) public onlyOwner {
        factory.createPool(token0, token1, _fee);
    }
    
    function getPool(address _token0, address _token1, uint24 _fee) external view returns (address) {
        address poolAddress = factory.getPool(_token0, _token1, _fee);
        return (poolAddress);
    }
    
    function getTokens(address _pool) external view returns (address, address) {
        address _token0 = IUniswapV3Pool(_pool).token0();
        address _token1 = IUniswapV3Pool(_pool).token1();
        return (_token0, _token1);
    }
    
    function initPool(address _pool, uint160 _price) external onlyOwner {  // input price data must be >=11 digits... price still 0 after init
        IUniswapV3Pool(_pool).initialize(_price);
    }
    
    function mintPool(address, _pool, uint128 _amount) external onlyOwner returns (uint256, uint256) {  // unable to call
        return IUniswapV3Pool(_pool).mint(msg.sender, _amount, MIN_TICK, MAX_TICK, abi.encode(address(this)));  
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
    

}    
