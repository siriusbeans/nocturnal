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
const LinkToken = artifacts.require("./Mocks/LinkToken.sol");
const WethToken = artifacts.require("./Mocks/WethToken.sol");

module.exports = function(deployer, network, accounts) {
    const ownerAddress = accounts[0];
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
    let LinkTokenInstance;
    let WethTokenInstance;

    deployer.then(function() {
        // Deploy first set of contracts, no interdependance
        return deployer.deploy(NocturnalFinance, { from: ownerAddress }).then(instance => {
            NocturnalFinanceInstance = instance;
            
            return deployer.deploy(LinkToken, { from: ownerAddress });
        }).then(instance => {
            LinkTokenInstance = instance;

            return deployer.deploy(WethToken, { from: ownerAddress });
        }).then(instance => {
            WethTokenInstance = instance;
            
        });
    }).then(function() {
  
            return deployer.deploy(Noct, NocturnalFinance.address, { from: ownerAddress }).then(instance => {
            NoctInstance = instance;
            
            return deployer.deploy(NoctStaking, NocturnalFinance.address, { from: ownerAddress });
        }).then(instance => {
            NoctStakingInstance = instance;
        
            return deployer.deploy(OrderFactory, NocturnalFinance.address, { from: ownerAddress });
        }).then(instance => {
            OrderFactoryInstance = instance;
            
            return deployer.deploy(OrderCreator, NocturnalFinance.address, WethToken.address, { from: ownerAddress });
        }).then(instance => {
            OrderCreatorInstance = instance;
            
            return deployer.deploy(OrderSettler, NocturnalFinance.address, WethToken.address, { from: ownerAddress });
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
            
            return deployer.deploy(Order, NocturnalFinance.address, { from: ownerAddress });
        }).then(instance => {
            OrderInstance = instance;
            
            return deployer.deploy(Rewards, NocturnalFinance.address, { from: ownerAddress });
        }).then(instance => {
            RewardsInstance = instance; 
               
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
                        OrderInstance.address);
    }).then(function() {

        return NocturnalFinanceInstance.initNoct(NoctInstance.address);
    }).then(function() {

        return NocturnalFinanceInstance.initsNoct(NoctStakingInstance.address);
    });
};
