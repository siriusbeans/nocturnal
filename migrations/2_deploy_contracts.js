"use strict";
const BigNumber = require("../node_modules/bignumber.js");
const Noct = artifacts.require("./Noct.sol");
const NoctStaking = artifacts.require("./NoctStaking.sol");
const NocturnalFinance = artifacts.require("./NocturnalFinance.sol");
const Oracle = artifacts.require("./Oracle.sol");
const Order = artifacts.require("./Order.sol");
const CreateOrder = artifacts.require("./CreateOrder.sol");
const DepositOrder = artifacts.require("./DepositOrder.sol");
const SettleOrder = artifacts.require("./SettleOrder.sol");
const CloseOrder = artifacts.require("./CloseOrder.sol");
const SettleOrderTransfer = artifacts.require("./SettleOrderTransfer.sol");
const Rewards = artifacts.require("./Rewards.sol");
const Treasury = artifacts.require("./Treasury.sol");
const DistributeRewards = artifacts.require("./DistributeRewards.sol");
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
    let NocturnalFinanceInstance;
    let OracleInstance;
    let OrderInstance;
    let CreateOrderInstance;
    let DepositOrderInstance;
    let SettleOrderInstance;
    let CloseOrderInstance;
    let SettleOrderTransferInstance;
    let RewardsInstance;
    let DistributeRewardsInstance;
    let TreasuryInstance;
    let TokenMinterInstance;
    let TokenSwapperInstance;

    deployer.then(function() {
        return deployer.deploy(NocturnalFinance, { from: ownerAddress }).then(instance => {
            NocturnalFinanceInstance = instance;
            
        return deployer.deploy(TokenMinter, LINK, WETH, { from: ownerAddress }).then(instance => {
            TokenMinterInstance = instance;
            
        return deployer.deploy(TokenSwapper, { from: ownerAddress }).then(instance => {
            TokenSwapperInstance = instance;
        });
    }).then(function() {
  
            return deployer.deploy(NoctStaking, NocturnalFinance.address, WETH, { from: ownerAddress }).then(instance => {
            NoctStakingInstance = instance;
            
            return deployer.deploy(CreateOrder, NocturnalFinance.address, WETH, { from: ownerAddress });
        }).then(instance => {
            CreateOrderInstance = instance;
            
            return deployer.deploy(DepositOrder, NocturnalFinance.address, WETH, { from: ownerAddress });
        }).then(instance => {
            DepositOrderInstance = instance;
            
            return deployer.deploy(SettleOrder, NocturnalFinance.address, WETH, { from: ownerAddress });
        }).then(instance => {
            SettleOrderInstance = instance;
            
            return deployer.deploy(CloseOrder, NocturnalFinance.address, WETH, { from: ownerAddress });
        }).then(instance => {
            CloseOrderInstance = instance;
            
            return deployer.deploy(SettleOrderTransfer, NocturnalFinance.address, { from: ownerAddress });
        }).then(instance => {
            SettleOrderTransferInstance = instance;
            
            return deployer.deploy(Oracle, { from: ownerAddress });
        }).then(instance => {
            OracleInstance = instance;
            
            return deployer.deploy(Order, NocturnalFinance.address, { from: ownerAddress });
        }).then(instance => {
            OrderInstance = instance;
            
            return deployer.deploy(Rewards, NocturnalFinance.address, rewardsSupply, initialSupply, { from: ownerAddress });
        }).then(instance => {
            RewardsInstance = instance; 
               
            return deployer.deploy(Treasury, NocturnalFinance.address, rewardsSupply, initialSupply, { from: ownerAddress });
        }).then(instance => {
            TreasuryInstance = instance;  
            
            return deployer.deploy(DistributeRewards, NocturnalFinance.address, { from: ownerAddress });
        }).then(instance => {
            DistributeRewardsInstance = instance;  
            
        });
    }).then(function() {

        return NocturnalFinanceInstance.initNocturnal(1, CreateOrderInstance.address);
    }).then(function() {

        return NocturnalFinanceInstance.initNocturnal(2, DepositOrderInstance.address);
    }).then(function() {

        return NocturnalFinanceInstance.initNocturnal(3, SettleOrderInstance.address);
    }).then(function() {

        return NocturnalFinanceInstance.initNocturnal(4, CloseOrderInstance.address);
    }).then(function() {

        return NocturnalFinanceInstance.initNocturnal(6, SettleOrderTransferInstance.address);
    }).then(function() {

        return NocturnalFinanceInstance.initNocturnal(7, OracleInstance.address);
    }).then(function() {

        return NocturnalFinanceInstance.initNocturnal(8, OrderInstance.address);
    }).then(function() {

        return NocturnalFinanceInstance.initNocturnal(9, RewardsInstance.address);
    }).then(function() {

        return NocturnalFinanceInstance.initNocturnal(10, TreasuryInstance.address);
    }).then(function() {

        return NocturnalFinanceInstance.initNocturnal(11, DistributeRewardsInstance.address);
    }).then(function() {
    
        return deployer.deploy(Noct, NocturnalFinance.address, rewardsSupply, initialSupply, { from: ownerAddress }).then(instance => {
        NoctInstance = instance;
        });
    }).then(function() {
    
        return NocturnalFinanceInstance.initNocturnal(12, NoctInstance.address);
    }).then(function() {

        return NocturnalFinanceInstance.initNocturnal(0, NoctStakingInstance.address);    
    }).then(function() {
    
        return NocturnalFinanceInstance.rewardsApproval();
    }).then(function() {
    
        return NocturnalFinanceInstance.treasuryApproval(); 
    }).then(function() {
    
        return NocturnalFinanceInstance.setPlatformRate(pRate);
    }).then(function() {

        return NocturnalFinanceInstance.setRewardsFactor(rFactor);
    }).then(function() {

        return NocturnalFinanceInstance.setTreasuryFactor(tFactor);
    }).then(function() {

        return NocturnalFinanceInstance.setOrderURI(uri); 
    });
});});};
