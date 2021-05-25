pragma solidity ^0.8.0;

import {TokenInterface} from "./TokenInterface.sol";

contract TokenMinter {
    
    constructor(address _link, address _weth) {
        TokenInterface(_link).mint(msg.sender, 1000000);
        TokenInterface(_weth).mint(msg.sender, 1000000);
    }
}    
