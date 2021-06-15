pragma solidity ^0.8.0;

import {TokenInterface} from "./TokenInterface.sol";

contract TokenMinter {
    
    address internal LINK;
    address internal WETH;
    
    constructor(address _link, address _weth) {
        LINK = _link;
        WETH = _weth;
    }
    
    function mintTokens(address _link, address _weth) external {
        TokenInterface(_link).mint(msg.sender, 1000);
        TokenInterface(_weth).mint(msg.sender, 1000);
    }
}  
