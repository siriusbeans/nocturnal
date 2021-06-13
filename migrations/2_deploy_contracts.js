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

module.exports = async function(deployer, network, accounts) {
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

    // need to deploy each contract one at a time for testing (in separate transaction)
    // all contracts' bytecode is less than 24Kb size limit
    // but during migration, max block gas limit is exceeded
    return deployer.deploy(NocturnalFinance, { from: ownerAddress }).then(NocturnalFinanceInstance => {

        return deployer.deploy(TokenMinter, LINK, WETH,  { from: ownerAddress }).then(async (TokenMinterInstance) => {
            return deployer.deploy(TokenSwapper,  { from: ownerAddress }).then(async (TokenSwapperInstance) => {
                return deployer.deploy(CreateOrder, NocturnalFinance.address, WETH,  { from: ownerAddress }).then(async (CreateOrderInstance) => {
                    return deployer.deploy(NoctStaking, NocturnalFinance.address, WETH,  { from: ownerAddress }).then(async (NoctStakingInstance) => {
                        return deployer.deploy(DepositOrder, NocturnalFinance.address, WETH,   { from: ownerAddress }).then(async (DepositOrderInstance) => {
                            return deployer.deploy(SettleOrder, NocturnalFinance.address, WETH,  { from: ownerAddress }).then(async (SettleOrderInstance) => {
                                return deployer.deploy(CloseOrder, NocturnalFinance.address, WETH, { from: ownerAddress }).then(async (CloseOrderInstance) => {
                                    return deployer.deploy(SettleOrderTransfer, NocturnalFinance.address, { from: ownerAddress }).then(async (SettleOrderTransferInstance) => {
                                        return deployer.deploy(Oracle,   { from: ownerAddress }).then(async (OracleInstance) => {
                                            return deployer.deploy(Order, NocturnalFinance.address, { from: ownerAddress }).then(async (OrderInstance) => {
                                                return deployer.deploy(Rewards, NocturnalFinance.address, rewardsSupply, initialSupply,  { from: ownerAddress }).then(async (RewardsInstance) => {
                                                    return deployer.deploy(Treasury, NocturnalFinance.address, 100, 100,  { from: ownerAddress }).then(async (TreasuryInstance) => {
                                                        return deployer.deploy(DistributeRewards, NocturnalFinance.address,  { from: ownerAddress }).then(async (DistributeRewardsInstance) => {
                                                            await NocturnalFinanceInstance.initNocturnal(1, CreateOrderInstance.address);
                                                            await NocturnalFinanceInstance.initNocturnal(2, DepositOrderInstance.address);
                                                            await NocturnalFinanceInstance.initNocturnal(3, SettleOrderInstance.address);
                                                            await NocturnalFinanceInstance.initNocturnal(4, CloseOrderInstance.address);
                                                            await NocturnalFinanceInstance.initNocturnal(6, SettleOrderTransferInstance.address);
                                                            await NocturnalFinanceInstance.initNocturnal(7, OracleInstance.address);
                                                            await NocturnalFinanceInstance.initNocturnal(8, OrderInstance.address);
                                                            await NocturnalFinanceInstance.initNocturnal(9, RewardsInstance.address);
                                                            await NocturnalFinanceInstance.initNocturnal(10, TreasuryInstance.address);
                                                            await NocturnalFinanceInstance.initNocturnal(11, DistributeRewardsInstance.address);
                                                            let NoctInstance = await deployer.deploy(Noct, NocturnalFinance.address, rewardsSupply, initialSupply, { from: ownerAddress });
                                                            await NocturnalFinanceInstance.initNocturnal(12, NoctInstance.address);
                                                            await NocturnalFinanceInstance.initNocturnal(0, NoctStakingInstance.address);    
                                                            await NocturnalFinanceInstance.setPlatformRate(pRate);
                                                            await NocturnalFinanceInstance.setRewardsFactor(rFactor);
                                                            await NocturnalFinanceInstance.setTreasuryFactor(tFactor);
                                                            await NocturnalFinanceInstance.setOrderURI(uri); 
        });
    });
});
});
});
});
});
});
});
});
});
});
        });
    });        
 
    
    /*
    deployer.then(function() {
            return deployer.deploy(NocturnalFinance, { from: ownerAddress });
        }).then(instance => {
            NocturnalFinanceInstance = instance;
            
        });
        
    deployer.then(function() {
            return deployer.deploy(TokenMinter, LINK, WETH, { from: ownerAddress });
        }).then(instance => {
            TokenMinterInstance = instance;
        });
            
    deployer.then(function() {            
            return deployer.deploy(TokenSwapper, { from: ownerAddress });
        }).then(instance => {
            TokenSwapperInstance = instance;
        });
        
    deployer.then(function() {            
            return deployer.deploy(CreateOrder, NocturnalFinance.address, WETH, { from: ownerAddress });
        }).then(instance => {
            CreateOrderInstance = instance;
        });
 
    deployer.then(function() {             
            return deployer.deploy(NoctStaking, NocturnalFinance.address, WETH, { from: ownerAddress });
        }).then(instance => {
            NoctStakingInstance = instance;
        });

    deployer.then(function() {                         
            return deployer.deploy(DepositOrder, NocturnalFinance.address, WETH, { from: ownerAddress });
        }).then(instance => {
            DepositOrderInstance = instance;
        });
         
    deployer.then(function() {                
            return deployer.deploy(SettleOrder, NocturnalFinance.address, WETH, { from: ownerAddress });
        }).then(instance => {
            SettleOrderInstance = instance;
        });

    deployer.then(function() {                  
            return deployer.deploy(CloseOrder, NocturnalFinance.address, WETH, { from: ownerAddress });
        }).then(instance => {
            CloseOrderInstance = instance;
        });
            
    deployer.then(function() {                  
            return deployer.deploy(SettleOrderTransfer, NocturnalFinance.address, { from: ownerAddress });
        }).then(instance => {
            SettleOrderTransferInstance = instance;
        });
            
    deployer.then(function() {                  
            return deployer.deploy(Oracle, { from: ownerAddress });
        }).then(instance => {
            OracleInstance = instance;
        });

    deployer.then(function() {                  
            return deployer.deploy(Order, NocturnalFinance.address, { from: ownerAddress });
        }).then(instance => {
            OrderInstance = instance;
        });

    deployer.then(function() {                             
            return deployer.deploy(Rewards, NocturnalFinance.address, rewardsSupply, initialSupply, { from: ownerAddress });
        }).then(instance => {
            RewardsInstance = instance; 
        });
           
    deployer.then(function() {                                 
            return deployer.deploy(Treasury, NocturnalFinance.address, { from: ownerAddress });
        }).then(instance => {
            TreasuryInstance = instance;  
        });
            
    deployer.then(function() {                                 
            return deployer.deploy(DistributeRewards, NocturnalFinance.address, { from: ownerAddress });
        }).then(instance => {
            DistributeRewardsInstance = instance;  
        });
            
    deployer.then(function() {

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
    
        return NocturnalFinanceInstance.setPlatformRate(pRate);
    }).then(function() {

        return NocturnalFinanceInstance.setRewardsFactor(rFactor);
    }).then(function() {

        return NocturnalFinanceInstance.setTreasuryFactor(tFactor);
    }).then(function() {

        return NocturnalFinanceInstance.setOrderURI(uri); 
    });
    */
};
