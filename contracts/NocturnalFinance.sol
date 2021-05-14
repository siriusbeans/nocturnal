pragma solidity ^0.6.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract NocturnalFinance is Ownable {
    
    address public oracleAddress;
    address public rewardsAddress;
    address public orderFactoryAddress;
    address public feeRateAdress;
    address public noctAddress;
    address public sNoctAddress;
    address public orderAddress;
    uint256 public depositRate;
    
    constructor() public {
    }
    
    function initNocturnal( 
            address _oracleAddress, 
            address _rewardsAddress,
            address _orderFactoryAddress,
            address _orderAddress,
            address _feeRateAddress) external onlyOwner {
		require(_oracleAddress != address(0));
		require(_rewardsAddress != address(0));
		require(_orderFactoryAddress != address(0));
		require(_orderAddress != address(0));
		require(_feeRateAddress != address(0));
        oracleAddress = _oracleAddress;
        rewardsAddress = _rewardsAddress;
        orderFactoryAddress = _orderFactoryAddress;
        feeRateAddress = _feeRateAddress;
    }
    
    function initNoct(address _noctAddress) external onlyOwner {
        require(_noctAddress != address(0));
        noctAddress = _noctAddress;
    }
    
    function initsNoct(address _sNoctAddress) external onlyOwner {
        require(_sNoctAddress != address(0));
        sNoctAddress = _sNoctAddress;
    }
    
    function setDepositRate(uint256 _dRateBasisPoints) external onlyOwner {
        depositRate = _dRateBasisPoints;
    }
}
