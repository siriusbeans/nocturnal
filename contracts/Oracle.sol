// SPDX-License-Identifier: MIT
pragma solidity 0.6.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/Uniswap/uniswap-v3-core/blob/main/contracts/interfaces/IUniswapV3Pool.sol";
import "https://github.com/Uniswap/uniswap-v3-core/blob/main/contracts/interfaces/IUniswapV3Factory.sol";

// NEXT:
// determine if liquidity should be known prior to executing a trade
// create a limit order contract that references this contract
// create an interface for this contract
// create the noct contract
// create an interface for the noct contract

contract uniswapOracle is Ownable {

    uint32 public twapDuration;
    
    constructor() public {
        twapDuration = 0;
    }

    function setTwapDuration(uint256 _duration) external onlyOwner {
        require(_duration <= 300, "TWAP duration must be less than 300 sec";
        twapDuration = _duration;
    }
    
    function getTwap(address _pool) external view onlyOwner returns (int24) {
        IUniswapV3Pool public pool;
        pool = IUniswapV3Pool(_pool);
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
    
    function getCurrentPrice(address _pool) internal view returns (int24 cPrice) {
        IUniswapV3Pool public pool;
        pool = IUniswapV3Pool(_pool);
        (, cPrice, , , , , ) = pool.slot0();
    }
    
    function getLiquidity(address _pool) external view onlyOwner returns (int128 cLiquidity) {
        IUniswapV3Pool public pool;
        pool = IUniswapV3Pool(_pool);
        cLiquidity = pool.liquidity();
    }
}
