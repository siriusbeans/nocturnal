pragma solidity ^0.8.0;

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenSwapper {
    using SafeMath for uint256;
    
    address internal constant UniswapV3SwapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564; // rinkeby swapRouter
    
    ISwapRouter public swapRouter;
    
    constructor(address _pool) {
        swapRouter = ISwapRouter(UniswapV3SwapRouter);
    }
    
    function getExactInputSingle(address _tokenIn, address _tokenOut, uint256 _amount) external returns (uint256 amountOut) {
        IERC20(_tokenIn).approve(UniswapV3SwapRouter, _amount);
        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amount);
		amountOut = swapRouter.exactInputSingle(
		ISwapRouter.ExactInputSingleParams({
		    tokenIn: _tokenIn,
		    tokenOut: _tokenOut,
		    fee: 10000,
		    recipient: msg.sender,
		    deadline: (block.timestamp).add(60),
		    amountIn: _amount,
		    amountOutMinimum: 0,
		    sqrtPriceLimitX96: 0
		    })
		);
    }
}    
