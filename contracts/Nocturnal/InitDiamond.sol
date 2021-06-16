// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

import {AppStorage} from "./libraries/LibAppStorage.sol";
import {LibMeta} from "../shared/libraries/LibMeta.sol";
import {LibDiamond} from "../shared/libraries/LibDiamond.sol";
import {IDiamondCut} from "../shared/interfaces/IDiamondCut.sol";
import {IERC165} from "../shared/interfaces/IERC165.sol";
import {IDiamondLoupe} from "../shared/interfaces/IDiamondLoupe.sol";
import {IERC173} from "../shared/interfaces/IERC173.sol";

contract InitDiamond {
    AppStorage internal s;

    struct Args {
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

    function init(Args memory _args) external {
        s.diamondAddress = _args.diamondAddress;
        s.createOrderFacetAddress = _args.createOrderFacetAddress;
        s.depositOrderFacetAddress = _args.depositOrderFacetAddress;
        s.settleOrderFacetAddress = _args.settleOrderFacetAddress;
        s.closeOrderFacetAddress = _args.closeOrderFacetAddress;
        s.oracleAddress = _args.oracleAddress;
        s.orderAddress = _args.orderAddress;
        s.rewardsAddress = _args.rewardsAddress;
        s.treasuryAddress = _args.treasuryAddress;
        s.distributeRewardsAddress = _args.distributeRewardsAddress;
        s.noctAddress = _args.noctAddress;
        s.noctStakingAddress = _args.noctStakingAddress;

        s.domainSeparator = LibMeta.domainSeparator("NocturnalDiamond", "V1");

        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        // adding ERC165 data
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;

        // add remaining NocturnalFinance.sol initialized variables here
        s.platformRate = _args.platformRate;
        s.rewardsRatioFactor = _args.rewardsRatioFactor;
        s.treasuryFactor = _args.treasuryFactor;
        s.orderURI = _args.orderURI; 
    }
}

