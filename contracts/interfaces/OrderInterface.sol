pragma solidity ^0.6.6;

interface OrderInterface {
    function ownerOf(uint256) external view returns (address);
    function burn(uint256) external returns ();
    function transferOrder(address, address, uint256) external returns ();
    function orderSwap(address, address, bool, uint256, uint160) external returns ();
    function _mint(address, uint256) external returns ();
}
