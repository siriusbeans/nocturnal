"use strict";
const BigNumber = require("../node_modules/bignumber.js");
const Noct = artifacts.require("./Noct.sol");
const NoctStaking = artifacts.require("./NoctStaking.sol");
const NocturnalFinance = artifacts.require("./NocturnalFinance.sol");
const Oracle = artifacts.require("./Oracle.sol");
const Order = artifacts.require("./Order.sol");
const OrderFactory = artifacts.require("./OrderFactory.sol");
const Rewards = artifacts.require("./Rewards.sol");

const WETH = "";

module.exports = function(deployer, network, accounts) {
    const ownerAddress = accounts[0];
    let NoctInstance;
    let NoctStakingInstance;
    let NocturnalFinanceInstance;
    let OracleInstance;
    let OrderInstance;
    let OrderFactoryInstance;
    let RewardsInstance;

    deployer.then(function() {
        // Deploy first set of contracts, no interdependance
        return deployer.deploy(NocturnalFinance, { from: ownerAddress }).then(instance => {
            NocturnalFinanceInstance = instance;
        });
    }).then(function() {
  
            return deployer.deploy(Noct, NocturnalFinance.address, { from: ownerAddress });
        }).then(instance => {
            NoctInstance = instance;
            
            return deployer.deploy(NoctStaking, NocturnalFinance.address, { from: ownerAddress });
        }).then(instance => {
            NoctStakingInstance = instance;
        
            return deployer.deploy(OrderFactory, NocturnalFinance.address, WETH { from: ownerAddress });
        }).then(instance => {
            OrderFactoryInstance = instance;
            
            return deployer.deploy(Oracle, NocturnalFinance.address, { from: ownerAddress });
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

        return NocturnalFinanceInstance.initNocturnal(OracleInstance.address, RewardsInstance.address, OrderFactoryInstance.address, OrderInstance.address);
        });
    }).then(function() {

        return NocturnalFinanceInstance.initNoct(NoctInstance.address);
        });
    }).then(function() {

        return NocturnalFinanceInstance.initsNoct(sNoctInstance.address);
    });
};
