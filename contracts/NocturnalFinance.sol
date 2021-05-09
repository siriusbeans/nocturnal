// SPDX-License-Identifier: MIT
pragma solidity 0.6.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract nocturnalFinance is Ownable {
    
    address internal noctAddress;
    address internal oracleAddress;
    uint256 internal oracleIndexCounter;
    
    mapping(uint256 => string) public oracleTitle;
    mapping(uint256 => address) public oracleToken0Address;
    mapping(uint256 => address) public oracleToken1Address;
    mapping(uint256 => uint256) public oraclePoolFee;
    
    constructor() public {
        oracleIndexCount = 0;
    }
    
    function init(address _noctAddress, address _oracleAddress) external onlyOwner { 
        require(_noctAddress != address(0));
        require(_oracleAddress != address(0));
        noctAddress = _noctAddress;
        oracleAddress = _oracleAddress;
    }
    
    function addOraclePair(string _oracleTitle, address _oracleToken0Address, address _oracleToken1Address, uint256 _oraclePoolFee, uint256 _oracleIndex, bool _overwrite) external onlyOwner {
        bytes memory oracleTitle = bytes(_oracleTitle);
        require(oracleTitle.length != 0, "empty oracle title");
        require(_oracleToken0Address != address(0));
        require(_oracleToken1Address != address(0));
        // .1% expressed as hundredths of a bip (1e-6) is 10000
        // .5% expressed as hundredths of a bip (1e-6) is 5000
        //  1% expressed as hundredths of a bip (1e-6) is 1000
        require((_oraclePoolFee == 10000) || (_oraclePoolFee == 5000) || (_oraclePoolFee == 1000), "invalid fee input");
        if (oracleIndexCounter != 0) {
            if (_overwrite == false) {
                require(_oracleIndex == oracleIndexCount, "invalid oracle index input");
            } else if (_overwrite == true) {
                require(_oracleIndex < oracleIndexCount, "oracle index does not exist, cannot be overwritten");
            }
        }
		
    	oracleTitle[oracleIndexCounter] = _oracleTitle;
    	oracleToken0Address[oracleIndexCounter] = _oracleToken0Address;
    	oracleToken1Address[oracleIndexCounter] = _oracleToken1Address;
    	oraclePoolFee[oracleIndexCounter] = _oraclePoolFee;
    	
    	if (_overwrite == false) {
    	    oracleIndexCounter = oracleIndexCounter++;
    	}
    }
    
    function getOracleCount() external view onlyOwner returns (uint256) {
        return oracleIndexCounter;
    }
    
    function getOracleTitle(uint256 _oracleIndex) external view onlyOwner returns (string) {
        require(_oracleIndex < oracleIndexCounter, "index out of range");
        return oracleTitle[_oracleIndex];
    }
    
    function getOracleToken0(uint256 _oracleIndex) external view onlyOwner returns (string) {
        require(_oracleIndex < oracleIndexCounter, "index out of range");
        return oracleToken0Address[_oracleIndex];
    }
    
    function getOracleToken1(uint256 _oracleIndex) external view onlyOwner returns (string) {
        require(_oracleIndex < oracleIndexCounter, "index out of range");
        return oracleToken1Address[_oracleIndex];
    }
    
    function getOraclePoolFee(uint256 _oracleIndex) external view onlyOwner returns (string) {
        require(_oracleIndex < oracleIndexCounter, "index out of range");
        return oraclePoolFee[_oracleIndex];
    }
}
