// SPDX-License-Identifier: MIT
pragma solidity 0.6.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract NocturnalFinance is Ownable {
    
    address internal noctAddress;
    address internal oracleAddress;
    address internal pickWinnerAddress;
    address internal rewardsAddress;
    address internal limitOrdersAddress;
    address internal poolsAddress;
    address internal gasPriceFeedAddress;
    
    uint256 internal volumeThreshold;
    uint256 internal batchMax;
    
    constructor() public {
    }
    
    function init(
            address _noctAddress, 
            address _oracleAddress, 
            address _pickWinnerAddress,
            address _rewardsAddress,
            address _limitOrdersAddress,
            address _poolsAddress,
            address _gasPriceAddress
            ) external onlyOwner { 
        require(_noctAddress != address(0));
        require(_oracleAddress != address(0));
        require(_pickWinnerAddress != address(0));
        require(_rewardsAddress != address(0));
        require(_limitOrdersAddress != address(0));
        require(_poolsAddress != address(0));
        require(_gasPriceAddress != address(0));
        noctAddress = _noctAddress;
        oracleAddress = _oracleAddress;
        pickWinnerAddress = _pickWinnerAddress;
        rewardsAddress = _rewardsAddress;
        limitOrdersAddress = _limitOrdersAddress;
        poolsAddress = _poolsAddress;
        gasPriceFeedAddress = _gasPriceAddress;
    }
    
    function setLotteryThreshold(uint256 _volumeThreshold) external onlyOwner {
        volumeThreshold = _volumeThreshold ether;
    }
    
    function setLotteryBatchSize(uint256 _batchMax) external onlyOwner {
        batchMax = _batchMax;
    }
    
}
