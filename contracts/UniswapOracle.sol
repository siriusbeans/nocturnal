// SPDX-License-Identifier: MIT
pragma solidity 0.6.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/Uniswap/uniswap-v3-core/blob/main/contracts/interfaces/IUniswapV3Pool.sol";
import "https://github.com/Uniswap/uniswap-v3-core/blob/main/contracts/interfaces/IUniswapV3Factory.sol";
import {NocturnalFinanceInterface} from "./NocturnalFinanceInterface.sol";

// NEXT:
// determine if liquidity should be known prior to executing a trade
// create a limit order contract that references this contract
// create an interface for this contract
// create the noct contract
// create an interface for the noct contract


contract uniswapOracle is Ownable {

    uint32 public twapDuration;
    address internal token0; 
    address internal token1;
    uint256 internal fee;

    IUniswapV3Factory public factory;
    IUniswapV3Pool public pool;
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance) public {
        twapDuration = 0;
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
    }
    
    function setPools(uint _oracleIndex) external onlyOwner {
        token0 = nocturnalFinance.oracleToken0Address[_oracleIndex];
        token1 = nocturnalFinance.oracleToken1Address[_oracleIndex];
        fee = nocturnalFinance.oraclePoolFee[_oracleIndex];
        address internal poolAddress = factory.getPool(token0, token1, fee); 
        pool = IUniswapV3Pool(poolAddress);
    }
    
    function setTwapDuration(uint256 _duration) external onlyOwner {
        require(_duration <= 300, "TWAP duration must be less than 300 sec";
        twapDuration = _duration;
    }
    
    function getTwap() external view onlyOwner returns (int24) {
        uint32 _twapDuration = twapDuration;
        if (_twapDuration == 0) {
            return getCurrentPrice();
        }
        
        uint32[] memory secondsAgo = new uint32[](2);
        secondsAgo[0] = _twapDuration;
        secondsAgo[1] = 0;

        (int56[] memory tickCumulatives, ) = pool.observe(secondsAgo);
        return int24((tickCumulatives[1] - tickCumulatives[0]) / _twapDuration);
    }
    
    function getCurrentPrice() internal view returns (int24 cPrice) {
        (, cPrice, , , , , ) = pool.slot0();
    }
    
    function getLiquidity() external view onlyOwner returns (int128 cLiquidity) {
        cLiquidity = pool.liquidity();
    }
}
