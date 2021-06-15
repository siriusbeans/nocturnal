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
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
//import "@uniswap/v3-periphery/contracts/interfaces/IPeripheryPayments.sol";
import {IERC20} from "../shared/interfaces/IERC20.sol";

import {AppStorage} from "./libraries/LibAppStorage.sol";

contract Order is ERC721Enumerable {
    AppStorage internal s;

    using SafeMath for uint256;

    address internal constant UniswapV3SwapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    
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
    
    constructor(address diamondAddress, string memory _URI) ERC721("Nocturnal Order", "oNOCT") {
        __name = "Nocturnal Order";
        __symbol = "oNOCT";
        __uriBase = _URI;
        swapRouter = ISwapRouter(UniswapV3SwapRouter);
    }
    
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        // concatinate _tokenId to __uriBase for tokenURI in future... 
        return (__uriBase);
    }
    
    function burn(uint256 tokenId) internal {
        //require(_msgSender() == s.closeOrderFacetAddress, "not nocturnal facet"); // diamond address?
        require(_msgSender() == diamondAddress, "not nocturnal diamond"); 
        _burn(tokenId);
    }
    
    function mint(address to, uint256 tokenId) internal {
        //require(_msgSender() == s.createOrderFacetAddress, "not nocturnal facet"); // diamond address?
        require(_msgSender() == diamondAddress, "not nocturnal diamond"); // diamond address?
        _mint(to, tokenId);
    }
    
    function getExactInputSingle(address _tokenIn, address _tokenOut, uint24 _fee, address _recipient, uint256 minOut, uint256 _amount) internal returns (uint256 amountOut) {
        //require(_msgSender() == s.settleOrderFacetAddress, "not nocturnal facet"); // diamond address?
        require(_msgSender() == diamondAddress, "not nocturnal diamond"); 
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
    
    function orderTransfer(address _tokenAddress, address _recipientAddress, uint256 _amount) internal {
        //require(_msgSender() == s.closeOrderFacetAddress || _msgSender() == s.settleOrderFacetAddress, "not nocturnal facet");  // diamond address?
        require(_msgSender() == diamondAddress, "not nocturnal diamond"); 
        require(IERC20(_tokenAddress).transfer(_recipientAddress, _amount), "order transfer amount failed");
    } 
    
    /*function orderPayout(address _recipientAddress, uint256 _amount) public {
        require(_msgSender() == s.settleOrderFacetAddress, "caller is not a nocturnal contract"); // diamond address?
        payment.unwrapWETH9(_amount, _recipientAddress);
    }*/
}
