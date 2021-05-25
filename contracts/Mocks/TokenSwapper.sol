pragma solidity ^0.8.0;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol";

contract TokenResource is IUniswapV3SwapCallback, Ownable {
    using SafeMath for uint256;
    
    //address internal constant UniswapV3SwapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564; // rinkeby swapRouter
    uint256 internal constant multiplicand = 1e18;
    uint256 public immutable MAXINT = type(uint256).max;
    address pool;
    address token0;
    address token1;
    
    ISwapRouter public swapRouter;
    
    constructor(address _pool) {
        swapRouter = ISwapRouter(address(0xE592427A0AEce92De3Edee1F18E0157C05861564));
        pool = _pool;
        token0 = IUniswapV3Pool(_pool).token0();
        token1 = IUniswapV3Pool(_pool).token1();
        IERC20(token0).approve(address(0xE592427A0AEce92De3Edee1F18E0157C05861564), type(uint256).max);
        IERC20(token1).approve(address(0xE592427A0AEce92De3Edee1F18E0157C05861564), type(uint256).max);
        IERC20(token0).approve(pool, type(uint256).max);
        IERC20(token1).approve(pool, type(uint256).max);
    }
    
    function approveContract() external {
        IERC20(token0).approve(address(this), MAXINT);
        IERC20(token1).approve(address(this), MAXINT);
    }
    
    function approveSwapRouter() external {
        IERC20(token0).approve(address(0xE592427A0AEce92De3Edee1F18E0157C05861564), MAXINT);
        IERC20(token1).approve(address(0xE592427A0AEce92De3Edee1F18E0157C05861564), MAXINT);
    }
    
    function approvePool() external {
        IERC20(token0).approve(address(pool), MAXINT);
        IERC20(token1).approve(address(pool), MAXINT);
    }
    
    function getExactInputSingle(address _tokenIn, address _tokenOut, uint256 _amount) external returns (uint256 amountOut) {
        //IERC20 token = IERC20(_tokenIn);
        //require(token.approve(UniswapV3SwapRouter, MAXINT), "approve failed");
	IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amount);
		amountOut = swapRouter.exactInputSingle(
		ISwapRouter.ExactInputSingleParams({
		    tokenIn: _tokenIn,
		    tokenOut: _tokenOut,
		    fee: 10000,
		    recipient: msg.sender,
		    deadline: (block.timestamp).add(120),
		    amountIn: _amount,
		    amountOutMinimum: 0,
		    sqrtPriceLimitX96: 0
		    })
		);
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
    
    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata) external override {
        require(msg.sender == address(pool));
        if (amount0Delta > 0) {
            IERC20(token0).transfer(msg.sender, uint256(amount0Delta));
        } else if (amount1Delta > 0) {
            IERC20(token1).transfer(msg.sender, uint256(amount1Delta));
        }
    }
}    
