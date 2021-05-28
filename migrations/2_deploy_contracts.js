"use strict";
const BigNumber = require("../node_modules/bignumber.js");
const Noct = artifacts.require("./Noct.sol");
const NoctStaking = artifacts.require("./NoctStaking.sol");
const NocturnalFinance = artifacts.require("./NocturnalFinance.sol");
const Oracle = artifacts.require("./Oracle.sol");
const Order = artifacts.require("./Order.sol");
const OrderManager = artifacts.require("./OrderManager.sol");
const CreateOrder = artifacts.require("./CreateOrder.sol");
const DepositOrder = artifacts.require("./DepositOrder.sol");
const SettleOrder = artifacts.require("./SettleOrder.sol");
const CloseOrder = artifacts.require("./CloseOrder.sol");
const ModifyOrder = artifacts.require("./ModifyOrder.sol");
const SettleOrderTransfer = artifacts.require("./SettleOrderTransfer.sol");
const Rewards = artifacts.require("./Rewards.sol");
const Treasury = artifacts.require("./Treasury.sol");
const DistributeRewards = artifacts.require("./DistributeRewards.sol");
const ValueInEth = artifacts.require("./ValueInEth.sol");
const TokenMinter = artifacts.require("./Mocks/TokenMinter.sol");
const TokenSwapper = artifacts.require("./Mocks/TokenSwapper.sol");

module.exports = function(deployer, network, accounts) {
    const ownerAddress = accounts[0]; 
    const initialSupply = 1100000;
    const rewardsSupply = 20900000;   
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
    let OrderManagerInstance;
    let CreateOrderInstance;
    let DepositOrderInstance;
    let SettleOrderInstance;
    let CloseOrderInstance;
    let ModifyOrderInstance;
    let SettleOrderTransferInstance;
    let RewardsInstance;
    let DistributeRewardsInstance;
    let ValueInEthInstance;
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
  
            return deployer.deploy(NoctStaking, NocturnalFinance.address, { from: ownerAddress }).then(instance => {
            NoctStakingInstance = instance;
        
            return deployer.deploy(OrderManager, NocturnalFinance.address, { from: ownerAddress });
        }).then(instance => {
            OrderManagerInstance = instance;
            
            return deployer.deploy(CreateOrder, NocturnalFinance.address, WETH, { from: ownerAddress });
        }).then(instance => {
            CreateOrderInstance = instance;
            
            return deployer.deploy(DepositOrder, NocturnalFinance.address, { from: ownerAddress });
        }).then(instance => {
            DepositOrderInstance = instance;
            
            return deployer.deploy(SettleOrder, NocturnalFinance.address, WETH, { from: ownerAddress });
        }).then(instance => {
            SettleOrderInstance = instance;
            
            return deployer.deploy(CloseOrder, NocturnalFinance.address, WETH, { from: ownerAddress });
        }).then(instance => {
            CloseOrderInstance = instance;
            
            return deployer.deploy(ModifyOrder, NocturnalFinance.address, { from: ownerAddress });
        }).then(instance => {
            ModifyOrderInstance = instance;
            
            return deployer.deploy(SettleOrderTransfer, NocturnalFinance.address, { from: ownerAddress });
        }).then(instance => {
            SettleOrderTransferInstance = instance;
            
            return deployer.deploy(Oracle, { from: ownerAddress });
        }).then(instance => {
            OracleInstance = instance;
            
            return deployer.deploy(ValueInEth, NocturnalFinance.address, WETH, { from: ownerAddress });
        }).then(instance => {
            ValueInEthInstance = instance;
            
            return deployer.deploy(Order, orderName, orderSymbol, NocturnalFinance.address, { from: ownerAddress });
        }).then(instance => {
            OrderInstance = instance;
            
            return deployer.deploy(Rewards, NocturnalFinance.address, rewardsSupply, { from: ownerAddress });
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

        return NocturnalFinanceInstance.initNocturnal(OracleInstance.address, 
                        RewardsInstance.address, 
                        OrderManagerInstance.address,
                        CreateOrderInstance.address,
                        DepositOrderInstance.address,
                        SettleOrderInstance.address, 
                        CloseOrderInstance.address, 
                        ModifyOrderInstance.address, 
                        SettleOrderTransferInstance.address, 
                        OrderInstance.address,
                        TreasuryInstance.address,
                        DistributeRewardsInstance.address,
                        ValueInEthInstance.address);
    }).then(function() {
    
        return deployer.deploy(Noct, NocturnalFinance.address, rewardsSupply, initialSupply, { from: ownerAddress }).then(instance => {
        NoctInstance = instance;
        });
    }).then(function() {
    
        return NocturnalFinanceInstance.initNoct(NoctInstance.address);
    }).then(function() {

        return NocturnalFinanceInstance.initsNoct(NoctStakingInstance.address);    
    }).then(function() {
    
        return NocturnalFinanceInstance.rewardsApproval();
    }).then(function() {
    
        return NocturnalFinanceInstance.treasuryApproval(); /*
    }).then(function() {
    
        return NocturnalFinanceInstance.setPlatformRate(pRate);
    }).then(function() {

        return NocturnalFinanceInstance.setRewardsFactor(rFactor);
    }).then(function() {

        return NocturnalFinanceInstance.setTreasuryFactor(tFactor);
    }).then(function() {

        return NocturnalFinanceInstance.setOrderURI(uri); */
    });
});});};
