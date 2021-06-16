"use strict";
const BigNumber = require("../node_modules/bignumber.js");

const Noct = artifacts.require("./Nocturnal/Noct.sol");
const NoctStaking = artifacts.require("./Nocturnal/NoctStaking.sol");
const Oracle = artifacts.require("./Nocturnal/Oracle.sol");
const Order = artifacts.require("./Nocturnal/Order.sol");
const Rewards = artifacts.require("./Nocturnal/Rewards.sol");
const Treasury = artifacts.require("./Nocturnal/Treasury.sol");
const DistributeRewards = artifacts.require("./Nocturnal/DistributeRewards.sol");
const InitDiamond = artifacts.require("./Nocturnal/initDiamond.sol");

const CreateOrderFacet = artifacts.require("./Nocturnal/facets/CreateOrderFacet.sol");
const DepositOrderFacet = artifacts.require("./Nocturnal/facets/DepositOrderFacet.sol");
const SettleOrderFacet = artifacts.require("./Nocturnal/facets/SettleOrderFacet.sol");
const CloseOrderFacet = artifacts.require("./Nocturnal/facets/CloseOrderFacet.sol");

const Diamond = artifacts.require("./shared/Diamond.sol");

const DiamondCutFacet = artifacts.require("./shared/facets/DiamondCutFacet.sol");
const DiamondLoupeFacet = artifacts.require("./shared/facets/DiamondLoupeFacet.sol");
const OwnershipFacet = artifacts.require("./shared/facets/OwnershipFacet.sol");

const TokenMinter = artifacts.require("./Mocks/TokenMinter.sol");
const TokenSwapper = artifacts.require("./Mocks/TokenSwapper.sol");

module.exports = function(deployer, network, accounts) {

    const toWei = (value) => web3.utils.toWei(value.toString(), "ether");
    const ownerAddress = accounts[0]; 
    const initialSupply = toWei(1100000);
    const rewardsSupply = toWei(20900000);   
    const orderName = "Nocturnal Order";
    const orderSymbol = "oNOCT";
    const pRate = 200;
    const rFactor = 8000;
    const tFactor = 2000;
    const uri = "tempURI";
    const WETH = "0x84fff9F8Bec0835494C4c9f43cfe32C7d37F82b5";
    const LINK = "0x27E1A4409fa79E5380aDE99ED289DBF342613Ce6";
    
    let NoctInstance;
    let NoctStakingInstance;
    let OracleInstance;
    let OrderInstance;
    let RewardsInstance;
    let DistributeRewardsInstance;
    let TreasuryInstance;
    let InitDiamondInstance;
    
    let CreateOrderFacetInstance;
    let DepositOrderFacetInstance;
    let SettleOrderFacetInstance;
    let CloseOrderFacetInstance;
    
    let DiamondInstance;
    
    let DiamondCutFacetInstance;
    let DiamondLoupeFacetInstance;
    let OwnershipFacetInstance;
    
    let TokenMinterInstance;
    let TokenSwapperInstance;

    deployer.then(function() {
      
        // Deploy the "mock" test-helper contracts
            return deployer.deploy(TokenMinter, LINK, WETH, { from: ownerAddress });
        }).then(instance => {
            TokenMinterInstance = instance;
            
            return deployer.deploy(TokenSwapper, { from: ownerAddress });
        }).then(instance => {
            TokenSwapperInstance = instance;
            
            
            
        // Deploy the non-facet Nocturnal Contracts
            return deployer.deploy(Noct, { from: ownerAddress });
        }).then(instance => {
            NoctInstance = instance;
            
            return deployer.deploy(NoctStaking, Noct.address, { from: ownerAddress });
        }).then(instance => {
            NoctStakingInstance = instance;
            
            return deployer.deploy(Oracle, { from: ownerAddress });
        }).then(instance => {
            OracleInstance = instance;
            
            return deployer.deploy(Order, uri, { from: ownerAddress });
        }).then(instance => {
            OrderInstance = instance;
            
            return deployer.deploy(Rewards, Noct.address, rewardsSupply, initialSupply, { from: ownerAddress });
        }).then(instance => {
            RewardsInstance = instance; 
               
            return deployer.deploy(Treasury, Noct.address, { from: ownerAddress });
        }).then(instance => {
            TreasuryInstance = instance;  
            
            return deployer.deploy(DistributeRewards, { from: ownerAddress });
        }).then(instance => {
            DistributeRewardsInstance = instance;   

            return deployer.deploy(InitDiamond, { from: ownerAddress });
        }).then(instance => {
            InitDiamondInstance = instance; 



        // Deploy the Nocturnal Facets
            return deployer.deploy(CreateOrderFacet, WETH, { from: ownerAddress });
        }).then(instance => {
            CreateOrderFacetInstance = instance;
            
            return deployer.deploy(DepositOrderFacet, { from: ownerAddress });
        }).then(instance => {
            DepositOrderFacetInstance = instance;
            
            return deployer.deploy(SettleOrderFacet, WETH, { from: ownerAddress });
        }).then(instance => {
            SettleOrderFacetInstance = instance;
            
            return deployer.deploy(CloseOrderFacet, { from: ownerAddress });
        }).then(instance => {
            CloseOrderFacetInstance = instance;
            
        
            
        // Deploy the Diamond
            return deployer.deploy(Diamond, ownerAddress, { from: ownerAddress });
        }).then(instance => {
            DiamondInstance = instance;
            
            
            
        // Deploy the shared Facets (redundant)
            return deployer.deploy(DiamondCutFacet, { from: ownerAddress });
        }).then(instance => {
            DiamondCutFacetInstance = instance;
            
            return deployer.deploy(DiamondLoupeFacet, { from: ownerAddress });
        }).then(instance => {
            DiamondLupeFacetInstance = instance;
            
            return deployer.deploy(OwnershipFacet, { from: ownerAddress });
        }).then(instance => {
            OwnershipFacetInstance = instance;
            
            
            
        // initialize initDiamond.sol and mint NOCT
        }).then(function() {

            return InitDiamondInstance.init( , { from: ownerAddress });
        }).then(function() {

            return NoctInstance.initialMint(Rewards.address, Treasury.address, rewardsSupply, initialSupply, { from: ownerAddress });
        });
        
        
        
        
        // SPECIFY DIAMOND FACETS

        // [CreateOrderFacet.address, Add, bytes4(keccak256("createOrder(CreateOrderParams calldata params)"))]
        
        // [DepositOrderFacet.address, Add, bytes4(keccak256("depositOrder(uint256 _orderID)"))]
        
        // [SettleOrderFacet.address, Add, bytes4(keccak256("settleOrder(uint256 _orderID)"))]
        
        // [SettleOrderFacet.address, Add, bytes4(keccak256("fromWETHSettle(uint256 _orderID, address _settler)"))]
        
        // [SettleOrderFacet.address, Add, bytes4(keccak256("toWETHSettle(uint256 _orderID, address _settler)"))]
        
        // [CloseOrderFacet.address, Add, bytes4(keccak256("closeOrder(uint256 _orderID)"))]
        
        
};
