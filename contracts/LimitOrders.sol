// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.1.0/contracts/math/SafeMath.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {NoctInterface} from "./Interfaces/NoctInterface.sol";

// NEXT:
// this must be written so that a single wallet can set multiple limit orders simultaneously
// that is with the same token pair, or various token pairs
// how will the limit orders be tracked?  mappings?  
// how can multiple orders be stored in a single address mapping?
// mapping to track volume ?  
// need volume tracked within contracts for lotto start require statement


contract LimitOrders is Ownable {
    using SafeMath for uint256;
    
    constructor() public {
    }
    
    function setSwapLimit() public {
    
    }
    
    function depositTokens() public {
    
    }
    
    function withdrawDepositedTokens() public {
    
    }
    
    function withdrawSwappedTokens() public {
    
    }
}
