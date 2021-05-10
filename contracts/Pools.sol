// SPDX-License-Identifier: MIT
pragma solidity 0.6.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Pools is Ownable {
   
    uint256 internal poolIndexCounter;
    
    mapping(uint256 => string) public poolTitle;
    mapping(uint256 => address) public poolToken0Address;
    mapping(uint256 => address) public poolToken1Address;
    mapping(uint256 => uint256) public poolFee;
    
    constructor() public {
        poolIndexCounter = 0;
    }
    
    // consider removing pool fee mapping
    // ideally, all fee pools will be checked within oracle contract
    // uniswap has stated additional fee pools may be added in future, as determined by DAO
    function addPool(string _poolTitle, address _poolToken0Address, address _poolToken1Address, uint256 _poolFee, uint256 _poolIndex, bool _overwrite) external onlyOwner {
        bytes memory poolTitle = bytes(_poolTitle);
        require(poolTitle.length != 0, "empty pair title");
        require(_poolToken0Address != address(0));
        require(_poolToken1Address != address(0));
        // .1% expressed as hundredths of a bip (1e-6) is 10000
        // .5% expressed as hundredths of a bip (1e-6) is 5000
        //  1% expressed as hundredths of a bip (1e-6) is 1000
        require((_poolFee == 10000) || (_poolFee == 5000) || (_poolFee == 1000), "invalid fee input");
        if (poolIndexCounter != 0) {
            if (_overwrite == false) {
		            require(_poolIndex == poolIndexCount, "invalid pool index input");
            } else if (_overwrite == true) {
                require(_poolIndex < poolIndexCount, "pool index does not exist, cannot be overwritten");
            }
        }
		
        poolTitle[poolIndexCounter] = _poolTitle;
        poolToken0Address[poolIndexCounter] = _poolToken0Address;
        poolToken1Address[poolIndexCounter] = _poolToken1Address;
        poolPoolFee[poolIndexCounter] = _poolFee;
    	
        if (_overwrite == false) {
            poolIndexCounter = poolIndexCounter++;
        }
    }
    
    function getPoolCount() external view onlyOwner returns (uint256) {
        return poolIndexCounter;
    }
    
    function getPoolTitle(uint256 _poolIndex) external view onlyOwner returns (string) {
        require(_poolIndex < poolIndexCounter, "index out of range");
        return poolTitle[_poolIndex];
    }
    
    function getPoolToken0(uint256 _poolIndex) external view onlyOwner returns (address) {
        require(_poolIndex < poolIndexCounter, "index out of range");
        return poolToken0Address[_poolIndex];
    }
    
    function getPoolToken1(uint256 _poolIndex) external view onlyOwner returns (address) {
        require(_poolIndex < poolIndexCounter, "index out of range");
        return poolToken1Address[_poolIndex];
    }
    
    function getPoolFee(uint256 _poolIndex) external view onlyOwner returns (uint256) {
        require(_poolIndex < poolIndexCounter, "index out of range");
        return poolFee[_poolIndex];
    }
}
