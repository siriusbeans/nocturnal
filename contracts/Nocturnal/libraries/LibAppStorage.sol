// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;
import {LibDiamond} from "../../shared/libraries/LibDiamond.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";

    struct OrderAttributes {
        address orderAddress;
        address poolAddress;
        address fromTokenAddress;
        address toTokenAddress;
        uint256 tokenBalance;
        uint256 limitPrice;
        bool limitType;
        uint256 amountOutMin;
        uint256 settlementGratuity;
        bool depositedFlag;
        bool settledFlag;
        bool closedFlag;
    }
    
    struct CreateOrderParams {
        address poolAddress;
        address fromTokenAddress;
        address toTokenAddress;
        uint256 tokenBalance;
        uint256 limitPrice;
        bool limitType;
        uint256 amountOutMin;
        uint256 settlementGratuity;
    }

    struct AppStorage {
        mapping (uint256 => OrderAttributes) _attributes;
        address diamondAddress;
        address createOrderFacetAddress;
        address depositOrderFacetAddress;
        address settleOrderFacetAddress;
        address closeOrderFacetAddress;
        address oracleAddress;
        address orderAddress;
        address rewardsAddress;
        address treasuryAddress;
        address distributeRewardsAddress;
        address noctAddress;
        address noctStakingAddress;
        uint256 platformRate;
        uint256 rewardsRatioFactor;
        uint256 treasuryFactor;
        string orderURI;
    }

library LibAppStorage {
    function diamondStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }
}

contract Modifiers {
    AppStorage internal s;
    modifier onlyOrderOwner(uint256 _orderId) {
        require(LibMeta.msgSender() == s.aavegotchis[_orderId].owner, "LibAppStorage: Only order owner can call this function");
        _;
    }
}

