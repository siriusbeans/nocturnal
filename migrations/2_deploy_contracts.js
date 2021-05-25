"use strict";
const BigNumber = require("../node_modules/bignumber.js");
const Noct = artifacts.require("./Noct.sol");
const NoctStaking = artifacts.require("./NoctStaking.sol");
const NocturnalFinance = artifacts.require("./NocturnalFinance.sol");
const Oracle = artifacts.require("./Oracle.sol");
const Order = artifacts.require("./Order.sol");
const OrderFactory = artifacts.require("./OrderFactory.sol");
const OrderCreator = artifacts.require("./OrderCreator.sol");
const OrderSettler = artifacts.require("./OrderSettler.sol");
const OrderCloser = artifacts.require("./OrderCloser.sol");
const OrderModifier = artifacts.require("./OrderModifier.sol");
const OrderTransfer = artifacts.require("./OrderTransfer.sol");
const Rewards = artifacts.require("./Rewards.sol");
const Treasury = artifacts.require("./Treasury.sol");
const TokenMinter = artifacts.require("./Mocks/TokenMinter.sol");

module.exports = function(deployer, network, accounts) {
    const ownerAddress = accounts[0]; 
    const initialSupply = 1100000;
    const rewardsSupply = 20900000;   
    const orderName = "Nocturnal Order";
    const orderSymbol = "oNOCT";
    const WETH = "0x84fff9F8Bec0835494C4c9f43cfe32C7d37F82b5";
    const LINK = "0x27E1A4409fa79E5380aDE99ED289DBF342613Ce6";
    let NoctInstance;
    let NoctStakingInstance;
    let NocturnalFinanceInstance;
    let OracleInstance;
    let OrderInstance;
    let OrderFactoryInstance;
    let OrderCreatorInstance;
    let OrderSettlerInstance;
    let OrderCloserInstance;
    let OrderModifierInstance;
    let OrderTransferInstance;
    let RewardsInstance;
    let TreasuryInstance;
    let TokenMinterInstance;

    deployer.then(function() {
        // Deploy first set of contracts, no interdependance
        return deployer.deploy(NocturnalFinance, { from: ownerAddress }).then(instance => {
            NocturnalFinanceInstance = instance;
            
        return deployer.deploy(TokenMinter, LINK, WETH, { from: ownerAddress }).then(instance => {
            TokenMinterInstance = instance;

        });
    }).then(function() {
  
            return deployer.deploy(NoctStaking, NocturnalFinance.address, { from: ownerAddress }).then(instance => {
            NoctStakingInstance = instance;
        
            return deployer.deploy(OrderFactory, NocturnalFinance.address, { from: ownerAddress });
        }).then(instance => {
            OrderFactoryInstance = instance;
            
            return deployer.deploy(OrderCreator, NocturnalFinance.address, WETH, { from: ownerAddress });
        }).then(instance => {
            OrderCreatorInstance = instance;
            
            return deployer.deploy(OrderSettler, NocturnalFinance.address, WETH, { from: ownerAddress });
        }).then(instance => {
            OrderSettlerInstance = instance;
            
            return deployer.deploy(OrderCloser, NocturnalFinance.address, { from: ownerAddress });
        }).then(instance => {
            OrderCloserInstance = instance;
            
            return deployer.deploy(OrderModifier, NocturnalFinance.address, { from: ownerAddress });
        }).then(instance => {
            OrderModifierInstance = instance;
            
            return deployer.deploy(OrderTransfer, NocturnalFinance.address, { from: ownerAddress });
        }).then(instance => {
            OrderTransferInstance = instance;
            
            return deployer.deploy(Oracle, { from: ownerAddress });
        }).then(instance => {
            OracleInstance = instance;
            
            return deployer.deploy(Order, orderName, orderSymbol, NocturnalFinance.address, { from: ownerAddress });
        }).then(instance => {
            OrderInstance = instance;
            
            return deployer.deploy(Rewards, NocturnalFinance.address, { from: ownerAddress });
        }).then(instance => {
            RewardsInstance = instance; 
               
            return deployer.deploy(Treasury, NocturnalFinance.address, { from: ownerAddress });
        }).then(instance => {
            TreasuryInstance = instance;  
            
        });
    }).then(function() {

        return NocturnalFinanceInstance.initNocturnal(OracleInstance.address, 
                        RewardsInstance.address, 
                        OrderFactoryInstance.address,
                        OrderCreatorInstance.address,
                        OrderSettlerInstance.address, 
                        OrderCloserInstance.address, 
                        OrderModifierInstance.address, 
                        OrderTransferInstance.address, 
                        OrderInstance.address,
                        TreasuryInstance.address);
    }).then(function() {
    
        return deployer.deploy(Noct, NocturnalFinance.address, rewardsSupply, initialSupply, { from: ownerAddress }).then(instance => {
        NoctInstance = instance;
        });
    }).then(function() {
    
        return NocturnalFinanceInstance.initNoct(NoctInstance.address);
    }).then(function() {

        return NocturnalFinanceInstance.initsNoct(NoctStakingInstance.address);
    });
};
