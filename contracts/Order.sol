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
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
//import "@uniswap/v3-periphery/contracts/interfaces/IPeripheryPayments.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {OracleInterface} from "./Interfaces/OracleInterface.sol";

contract Order is ERC721Enumerable {
    using SafeMath for uint256;

    address internal constant UniswapV3SwapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    
    NocturnalFinanceInterface public nocturnalFinance;
    IUniswapV3Pool public pool;
    ISwapRouter public swapRouter;
    
    // Token name
    string private __name;

    // Token symbol
    string private __symbol;
    
    // Token baseURI
    string private __uriBase;
    
    uint[] internal tokenIndexes;
    
    mapping(uint => uint) internal indexTokens; 
    mapping(address => uint[]) internal ownerTokenIndexes;
    mapping(uint => uint) internal tokenTokenIndexes;
    
    constructor(address _nocturnalFinance) ERC721("Nocturnal Order", "oNOCT") {
        __name = "Nocturnal Order";
        __symbol = "oNOCT";
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
        __uriBase = nocturnalFinance.orderURI();
        swapRouter = ISwapRouter(UniswapV3SwapRouter);
    }
    
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        // concatinate _tokenId to __uriBase for tokenURI in future... 
        return (__uriBase);
    }
    
    function burn(uint256 tokenId) public {
        require(_msgSender() == nocturnalFinance._contract(4), "not CloseOrder contract");
        _burn(tokenId);
    }
    
    function mint(address to, uint256 tokenId) public {
        require(_msgSender() == nocturnalFinance._contract(1), "not CreateOrder contract");
        _mint(to, tokenId);
    }
    
    function getExactInputSingle(address _tokenIn, address _tokenOut, uint24 _fee, address _recipient, uint256 minOut, uint256 _amount) external returns (uint256 amountOut) {
        require(_msgSender() == nocturnalFinance._contract(6), "caller is not a nocturnal contract");
        require(IERC20(_tokenIn).approve(UniswapV3SwapRouter, _amount), "approve failed");
		amountOut = swapRouter.exactInputSingle(
		    ISwapRouter.ExactInputSingleParams({
		        tokenIn: _tokenIn,
		        tokenOut: _tokenOut,
		        fee: _fee,
		        recipient: _recipient,
		        deadline: block.timestamp + 600, // 10 minutes from current block
		        amountIn: _amount,
		        amountOutMinimum: minOut, 
		        sqrtPriceLimitX96: 0
		    })
		);
    }
    
    function orderTransfer(address _tokenAddress, address _recipientAddress, uint256 _amount) public {
        require(_msgSender() == nocturnalFinance._contract(4) || _msgSender() == nocturnalFinance._contract(6), "caller is not a nocturnal contract");
        require(IERC20(_tokenAddress).transfer(_recipientAddress, _amount), "order transfer amount failed");
    } 
    
    /*function orderPayout(address _recipientAddress, uint256 _amount) public {
        require(_msgSender() == nocturnalFinance._contract(6), "caller is not a nocturnal contract");
        payment.unwrapWETH9(_amount, _recipientAddress);
    }*/
}
