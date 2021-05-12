pragma solidity ^0.6.6;

interface OrderFactoryInterface {
    function createLimitOrder(
            address _swapPoolAddress, 
            address _swapFromTokenAddress, 
            address _swapToTokenAddress, 
            uint256 _swapFromTokenBalance, 
            uint256 _swapLimitPrice,
            bool _swapAbove,
            uint256 _swapSlippage, 
            uint256 _swapSettlementFee) external returns ();
    function settleLimitOrder(address) external returns ();
    function closeLimitOrder(address) external returns ();
}
