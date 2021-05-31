const BigNumber = require("bignumber.js");
const NocturnalFinance = artifacts.require("./NocturnalFinance.sol");
const Noct = artifacts.require("./Noct.sol");
const NoctStaking = artifacts.require("./NoctStaking.sol");
const Oracle = artifacts.require("./Oracle.sol");
const Order = artifacts.require("./Order.sol");
const OrderSlippage = artifacts.require("./OrderSlippage.sol");
const CreateOrder = artifacts.require("./CreateOrder.sol");
const SettleOrder = artifacts.require("./SettleOrder.sol");
const CloseOrder = artifacts.require("./CloseOrder.sol");
const Rewards = artifacts.require("./Rewards.sol");
const Treasury = artifacts.require("./Treasury.sol");
const TokenMinter = artifacts.require("./Mocks/TokenMinter.sol");
const TokenSwapper = artifacts.require("./Mocks/TokenSwapper.sol");
const LinkToken = artifacts.require("./Mocks/LinkToken.sol");
const WethToken = artifacts.require("./Mocks/WethToken.sol");
const SettleOrderTransfer = artifacts.require("./SettleOrderTransfer.sol");
const DistributeRewards = artifacts.require("./DistributeRewards.sol");

contract('CreateOrder_WETH_token1_fromToken_above', accounts => {
    const owner = accounts[0];
    let NocturnalFinanceInstance;
    let NoctInstance;
    let NoctStakingInstance;
    let OracleInstance;
    let OrderInstance;
    let OrderSlippageInstance;
    let CreateOrderInstance;
    let SettleOrderInstance;
    let CloseOrderInstance;
    let SettleOrderTransferInstance;
    let RewardsInstance;
    let TreasuryInstance;
    let TokenMinterInstance;
    let TokenSwapperInstance;
    let DistributeRewardsInstance;
    let orderID;
    let orderAddress;
    const toWei = (value) => web3.utils.toWei(value.toString(), "ether");
    const testAddressCount = 3;  
    const orderURI = "";
    const depositRate = 200;  // 2% of fromToken (basis points)
    const treasuryFactor = 2000; // 20% of total rewards to treasury (basis points)
    const rewardsFactor = 8000;  // 80% of (total rewards - treasury allocation) to creators, 20% to settlers (basis points)
    const poolAddress = "0xEa9ab84751A2ef0db5f3601aE8EC0F1E4798728B"; // LINK/WETH pool address
    const fromTokenAddress = "0x84fff9F8Bec0835494C4c9f43cfe32C7d37F82b5"; // WETH address
    const toTokenAddress = "0x27E1A4409fa79E5380aDE99ED289DBF342613Ce6"; // LINK address
    const fromTokenBalance = toWei(100); // 100 tokens in wei
    const limitPrice = toWei(2);  // price in wei
    const slippage = 500; // 5% slippage (basis points)
    const limitType = true;
    const settlementGratuity = 200; // 2% of fromToken (basis points)
//=============================================================================================//    
//=============================================================================================//      
    async function createOrder() {
    	it("creates a new order", async () => {
            let order = await CreateOrderInstance.createOrder(
            	[poolAddress,
                fromTokenAddress,
                toTokenAddress,
                fromTokenBalance,
                limitPrice,
                slippage,
                limitType,
                settlementGratuity]
            );     
        });
    };   
//=============================================================================================//
//=============================================================================================//    
    before("setup", async () => {
        NocturnalFinanceInstance = await NocturnalFinance.deployed();
        NoctInstance = await Noct.deployed();
        NoctStakingInstance = await NoctStaking.deployed();
        TreasuryInstance = await Treasury.deployed();
        RewardsInstance = await Rewards.deployed();
        OracleInstance = await Oracle.deployed();
        OrderInstance = await Order.deployed();
        OrderSlippageInstance = await OrderSlippage.deployed();
        SettleOrderTransferInstance = await SettleOrderTransfer.deployed();
    	CreateOrderInstance = await CreateOrder.deployed();
    	SettleOrderInstance = await SettleOrder.deployed();
    	CloseOrderInstance = await CloseOrder.deployed();
    	RewardsInstance = await Rewards.deployed();
    	TokenMinterInstance = await TokenMinter.deployed();
    	TokenSwapperInstance = await TokenSwapper.deployed();
    	DistributeRewardsInstance = await DistributeRewards.deployed();
    });

    describe("tests new order creation", async () => {
        before("set depositRate to " + depositRate + " basis points", () => 
            NocturnalFinanceInstance.setPlatformRate(depositRate)
        );
        
        before("set treasuryFactor to " + treasuryFactor + " basis points", () => 
            NocturnalFinanceInstance.setTreasuryFactor(treasuryFactor)
        );
        
        before("set rewardsFactor to " + rewardsFactor + " basis points", () => 
            NocturnalFinanceInstance.setRewardsFactor(rewardsFactor)
        );
        
        before("set orderURI to " + orderURI, () => 
            NocturnalFinanceInstance.setOrderURI(orderURI)
        );

        before("seed addresses with MOCK0 and MOCK1 tokens", async () => {
            for (let i = 0; i < accounts.length-1; i++) {
                await TokenMinterInstance.mintTokens(fromTokenAddress, toTokenAddress);
            }
        });
        
        before("approve orderCreator.sol allowance", async () => {
            let WethTokenInstance = await WethToken.at(fromTokenAddress);
            for (let i = 0; i < accounts.length-1; i++) {
                await WethTokenInstance.approve(CreateOrderInstance.address, fromTokenBalance, { from : accounts[0] });
            }
        }); 
        
        //create a new limit order
        createOrder();
        // get order address from orderCreated emitted event
        // check new order attributes
        // check creator address balance
        // check order address balance
        // check staking contract balance
       
    });
});
