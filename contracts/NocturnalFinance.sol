// SPDX-License-Identifier: MIT
pragma solidity 0.6.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract NocturnalFinance is Ownable {
    
    address internal noctAddress;
    address internal oracleAddress;
    address internal rewardsAddress;
    address internal orderFactoryAddress;
    
    constructor() public {
    }
    
    function initNocturnal( 
            address _oracleAddress, 
            address _rewardsAddress,
            address _orderFactoryAddress) external onlyOwner {
		require(_oracleAddress != address(0));
		require(_rewardsAddress != address(0));
		require(_orderFactoryAddress != address(0));
        oracleAddress = _oracleAddress;
        rewardsAddress = _rewardsAddress;
        orderFactoryAddress = _orderFactoryAddress;
    }
    
    function initNoct(address _noctAddress) external onlyOwner {
        require(_noctAddress != address(0));
        noctAddress = _noctAddress;
    }
    
}
