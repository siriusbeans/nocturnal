// SPDX-License-Identifier: MIT
pragma solidity 0.6.6;

import "https://github.com/Uniswap/uniswap-v3-core/blob/main/contracts/interfaces/IUniswapV3Pool.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";

contract uniswapOracle {

    IUniswapV3Pool public pool;
    
    constructor() public {
    }
   
    function getCurrentPrice(address _pool) external view returns (int24 cPrice) {
        pool = IUniswapV3Pool(_pool);
        (, cPrice, , , , , ) = pool.slot0();
    }
}
