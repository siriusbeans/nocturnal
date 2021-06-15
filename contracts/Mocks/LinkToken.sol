
// Token contract on Rinkeby Testnet, representing the xxxx token.
// Call mint(_amount) for unlimited tokens.

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract LinkToken is ERC20 ("Mock0 Token", "MOCK0") {
    using SafeMath for uint256;

    constructor () {
    }
    
    function mint(address _address, uint256 _amount) public {
        _mint(_address, _amount.mul(1e18));
    }
    
    function approve(address sender, uint256 _amount) public override returns (bool) {
        _approve(msg.sender, sender, _amount);
        return (true);
    }
}
