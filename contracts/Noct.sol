pragma solidity ^0.6.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";

contract Noct is ERC20 ("Nocturnal Token", "NOCT") {
    using SafeMath for uint256;

    NocturnalFinanceInterface public nocturnalFinance;

    constructor (address _nocturnalFinance) public {
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
        _mint(nocturnalFinance.rewardsAddress(), 22000000 * 10 ** uint256(decimals()));
    }
}
