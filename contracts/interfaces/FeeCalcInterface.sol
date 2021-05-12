pragma solidity ^0.6.6;

interface FeeCalcInterface {
    function getDepositFee() external view returns (uint256);
}
