// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "https://github.com/smartcontractkit/chainlink/blob/master/evm-contracts/src/v0.6/VRFConsumerBase.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import {NocturnalFinanceInterface} from "./Interfaces/NocturnalFinanceInterface.sol";
import {NoctInterface} from "./Interfaces/NoctInterface.sol";

// NEXT:
// Reward Public function callers with NOCT (Rewards.sol)
// Generate events whenever public functions need to be called to complete lottery process
// Generate an event when the platform volume exceeds the lottery volume threshold
// Create mapping that tracks winner addresses and whether or not they have claimed their jackpot
// Modify PickWinner so that lottery flags reset properly after winner address is found 
// Create mapping that tracks the Chainlink VRF for each lottery drawing -> getLottoVRF(uint256 _snapID) 

contract PickWinner is VRFConsumerBase, Ownable {
    using SafeMathChainlink for uint256;
	
    address public winner;
    uint256 public snapID;
    bytes32 internal reqId;
    bytes32 internal keyHash;
    uint256 public noctSupply;
    uint256 public batchSize;
    uint256 public batchCount;
    bool public lotteryStartFlag;
    bool public drawStartFlag;
    bool public winnerFoundFlag;
    uint256 public winningIndex;
    uint256 public randomNumber;
    uint256 public sumOfWeights;
    uint256 public batchRemainder;
    uint256 internal oraclePayment;
    uint256 public noctAddressCount;
    bool public weightsAssignedFlag;
    address internal vrfCoordinator;
    uint256 internal lottoResolution;
    bool public randomNumberRequestFlag;
    bool public randomNumberReceivedFlag;
    uint256 public buildArrayBatchCounter;
    uint256 public findWinnerBatchCounter;
    uint256 public addressWeightArrayIndexMin;
    uint256 public addressWeightArrayIndexMax;
    
    mapping(address => uint256) public addressWeight;
    mapping(address => uint256) internal minWeightRangeIndex;
    mapping(address => uint256) internal maxWeightRangeIndex;
    //mapping(address => mapping(uint256 => uint256)) public snapshotWeight;
    
    NocturnalFinanceInterface public nocturnalFinance;
    
    constructor(address _nocturnalFinance) VRFConsumerBase(0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, 0x01BE23585060835E02B77ef475b0Cc51aA1e0709) public {
    	keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311; 
        vrfCoordinator = 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B;
        nocturnalFinance = NocturnalFinanceInterface(_nocturnalFinance);
        randomNumberReceivedFlag = false;
        randomNumberRequestFlag = false;
        addressWeightArrayIndexMin = 0;
        addressWeightArrayIndexMax = 0;
        weightsAssignedFlag = false;
        oraclePayment = 0.1*10**18;
        buildArrayBatchCounter = 0;
        findWinnerBatchCounter = 0;
        lottoResolution = 10**7; // make minimum for lotto entry equal 1 NOCT -> lottoResolution will need to be modified
        lotteryStartFlag = false;
        drawStartFlag = false;
        batchRemainder = 0;
        sumOfWeights = 1;
        randomNumber = 0;
        winningIndex = 0;
        batchCount = 0;
        batchSize = 0;
        snapID = 0;
        reqId = 0;
    }
    
    function getSnapBalance(address _addy, uint256 _snapID) public view returns (uint256) {
        require(_snapID <= snapID, "snapID too large");
    	uint256 snapBalance = NoctInterface(nocturnalFinance.noctAddress()).balanceOfAt(_addy, snapID);
    	return snapBalance;
    }
    
    //function getSnapWeight(address _addy, uint256 _snapID) public view returns (uint256) {
    //    require(_snapID <= snapID, "snapID too large");
    //create mapping of a mapping to track weight of each address at each snapshot ... ???
    //mapping(address => mapping(uint256 => uint256)) ... ???
    //mapping must be updated within buildAddressWeightArray() function ... ???
    //snapWeight = snapshotWeight(_addy) ... ???
    //    return snapWeight;
    //}
    
    //function getLottoStartTimestamp(uint256 _snapID) {
    //
    //}
    
    //function getLottoEndTimestamp(uint256 _snapID) {
    //
    //}
    
    //function getLottoVRF(uint256 _snapID) {
    //
    //}
    
    function getTotalLottoDrawings() public view returns (uint256) {
        return snapID;
    }
    
    function getBalance(address _addy) public view returns (uint256) {
        uint256 balance = NoctInterface(NocturnalFinance.noctAddress()).balanceOf(_addy);
        return balance;
    }
    
    function getWeight(address _addy) public view returns (uint256) {
    	uint256 weight = addressWeight[_addy];
    	return weight;
    }

    function startLottery() public {
        require(lotteryStartFlag == false, "lottery has already started");
        //require( (tracked volume from another contract) > nocturnalFinance.volumeThreshold(), "trading volume threshold has not been reached");
        snapID = NoctInterface(nocturnalFinance.noctAddress()).snapshot();
        noctAddressCount = NoctInterface(nocturnalFinance.noctAddress()).holderCount();
        noctSupply = NoctInterface(nocturnalFinance.noctAddress()).totalSupply();
        batchSize = nocturnalFinance.batchMax();
        batchCount = noctAddressCount.div(batchSize);
        batchRemainder = noctAddressCount.mod(batchSize);
        lotteryStartFlag = true;
    }
    
    function buildAddressWeightArray() public {
        require(lotteryStartFlag == true, "lottery has not started, yet");
        require(weightsAssignedFlag == false, "weights assignments are complete");
        uint256 noctBalance = 0;
        uint256 noctWeight = 0;
        addressWeightArrayIndexMin = buildArrayBatchCounter.mul(batchSize);
        if (batchRemainder != 0) {
	    if (buildArrayBatchCounter < batchCount) {
                addressWeightArrayIndexMax = addressWeightArrayIndexMin.add(batchSize);
            } else {
                addressWeightArrayIndexMax = addressWeightArrayIndexMin.add(batchRemainder);
            }
        } else {
            addressWeightArrayIndexMax = addressWeightArrayIndexMin.add(batchSize);
        }
        for (uint256 i = addressWeightArrayIndexMin; i < addressWeightArrayIndexMax; i++) {
            noctBalance = noctInterface(nocturnalFinance.noctAddress()).balanceOfAt(NoctInterface(nocturnalFinance.noctAddress()).holders(i), snapID);
            noctWeight = noctBalance.mul(lottoResolution).div(noctSupply);
            if (noctWeight > 0) {
                minWeightRangeIndex[NoctInterface(nocturnalFinance.noctAddress()).holders(i)] = sumOfWeights;
                sumOfWeights = sumOfWeights.add(noctWeight);
                maxWeightRangeIndex[NoctInterface(nocturnalFinance.noctAddress()).holders(i)] = sumOfWeights;
                addressWeight[NoctInterface(nocturnalFinance.noctAddress()).holders(i)] = noctWeight;
            }
        }
        buildArrayBatchCounter++;
        if ((batchRemainder != 0) && (buildArrayBatchCounter > batchCount)) {
            weightsAssignedFlag = true;
        } else if ((batchRemainder == 0) && (buildArrayBatchCounter == batchCount)) {
            weightsAssignedFlag = true;
        }        
    }   
    
    function getRandomNumber() public {
        require(weightsAssignedFlag == true, "weights are not assigned, yet");
        require(randomNumberRequestFlag == false, "random number request is complete");
        requestRandomness(keyHash, oraclePayment, block.number);
        randomNumberRequestFlag = true;
    }
    
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        require(msg.sender == vrfCoordinator);
        require(randomNumberRequestFlag == true);
        reqId = requestId;
        randomNumber = randomness;
        randomNumberReceivedFlag = true;
    }
    
    function determineWinningIndex() public {
        require(randomNumberReceivedFlag == true, "random number not received");
        require(drawStartFlag == false, "winning Index was already selected");
        drawStartFlag = true;
        winningIndex = (randomNumber.mod(sumOfWeights.sub(1))).add(1);
    }
    
    function findWinner() public {
        require(drawStartFlag == true, "winning Index has yet to be determined");
        require(winnerFoundFlag == false, "winning address was already found");
        uint256 minIndex = 0;
        uint256 maxIndex = 0;
        addressWeightArrayIndexMin = findWinnerBatchCounter.mul(batchSize);
        if (findWinnerBatchCounter < batchCount) {
            addressWeightArrayIndexMax = addressWeightArrayIndexMin.add(batchSize);
        } else {
            addressWeightArrayIndexMax = addressWeightArrayIndexMin.add(batchRemainder);
        }
        for (uint256 i = addressWeightArrayIndexMin; i < addressWeightArrayIndexMax; i++) {
            minIndex = minWeightRangeIndex[NoctInterface(nocturnalFinance.noctAddress()).holders(i)];
            maxIndex = maxWeightRangeIndex[NoctInterface(nocturnalFinance.noctAddress()).holders(i)];
            if ((winningIndex >= minIndex) && (winningIndex < maxIndex)) {
                winner = NoctInterface(nocturnalFinance.noctAddress()).holders(i);
                winnerFoundFlag = true;
                // add winner address jackpot amount to appropriate mapping
                // to allow the winner address to claim rewards (will be referenced in Rewards.sol) 
		// add event firing winner address ?
            }
        }
        findWinnerBatchCounter++;
	if (winnerFoundFlag == true) {
            resetFlags()
	}
    }
    
    function resetFlags() internal {
        randomNumberReceivedFlag = false;
        randomNumberRequestFlag = false;
        emergencyWithdrawalFlag = false;
        addressWeightArrayIndexMax = 0;
        addressWeightArrayIndexMin = 0;
        weightsAssignedFlag = false;
        buildArrayBatchCounter = 0;
        findWinnerBatchCounter = 0;
        winnerFoundFlag = false;
        drawStartFlag = false;
        lotteryStartFlag = false;
        noctAddressCount = 0;
        sumOfWeights = 1;
        randomNumber = 0;
        winningIndex = 0;
        batchCount = 0;
        keySupply = 0;
        batchSize = 0;
        reqId = 0;
    }
}
