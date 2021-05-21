pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Mock0 is Ownable, ERC20 ("Mock0 Token", "MOCK0") {
    using SafeMath for uint256;

    constructor () {
    }
    
    function mintMock(uint256 _amount) public onlyOwner {
        _mint(msg.sender, _amount.mul(10).mul(1e18);
    }
}
