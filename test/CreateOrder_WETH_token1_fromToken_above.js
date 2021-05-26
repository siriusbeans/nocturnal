const BigNumber = require("bignumber.js");
const truffleAssert = require('truffle-assertions');
const NocturnalFinance = artifacts.require("./NocturnalFinance.sol");
const Noct = artifacts.require("./Noct.sol");
const NoctStaking = artifacts.require("./NoctStaking.sol");
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
const TokenSwapper = artifacts.require("./Mocks/TokenSwapper.sol");

contract('CreateOrder_WETH_token1_fromToken_above', accounts => {
    const owner = accounts[0];
    let NocturnalFinanceInstance;
    let NoctInstance;
    let NoctStakingInstance;
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
    let TokenSwapperInstance;
    let orderID;
    let orderAddress;
    const testAddressCount = 3;  
    const orderURI = "";
    const depositRate = 200;  // 2% of fromToken (basis points)
    const treasuryFactor = 2000; // 20% of total rewards to treasury (basis points)
    const rewardsFactor = 8000;  // 80% of (total rewards - treasury allocation) to creators, 20% to settlers (basis points)
    const swapPoolAddress = "0xEa9ab84751A2ef0db5f3601aE8EC0F1E4798728B"; // LINK/WETH pool address
    const swapFromTokenAddress = "0x84fff9F8Bec0835494C4c9f43cfe32C7d37F82b5"; // WETH address
    const swapToTokenAddress = "0x27E1A4409fa79E5380aDE99ED289DBF342613Ce6"; // LINK address
    const swapFromTokenBalance = 1*(1e18); // 100 tokens in wei
    const swapLimitPrice = 2*(1e18);  // price*(1e18)
    const swapSlippage = 500; // 5% slippage (basis points)
    const swapAbove = true;
    const swapSettlementGratuity = 200; // 2% of fromToken (basis points)
//=============================================================================================//    
//=============================================================================================//      

    async function createLimitOrder() {
    	it("creates a new limit order", () => {
            let order = OrderFactoryInstance.createLimitOrder(
            	swapPoolAddress,
                swapFromTokenAddress,
                swapToTokenAddress,
                swapFromTokenBalance,
                swapLimitPrice,
                swapSlippage,
                swapAbove,
                swapSettlementGratuity);  
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
        OrderFactoryInstance = await OrderFactory.deployed();
        OrderTransferInstance = await OrderTransfer.deployed();
    	OrderCreatorInstance = await OrderCreator.deployed();
    	OrderSettlerInstance = await OrderSettler.deployed();
    	OrderCloserInstance = await OrderCloser.deployed();
    	OrderModifierInstance = await OrderModifier.deployed();
    	RewardsInstance = await Rewards.deployed();
    	TokenMinterInstance = await TokenMinter.deployed();
    	TokenSwapperInstance = await TokenSwapper.deployed();
    });

    describe("test new limit order creation", async () => {
        before("set depositRate to " + depositRate + " basis points", () => 
            NocturnalFinanceInstance.setDepositRate(depositRate)
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
                await TokenMinterInstance.mintTokens(swapFromTokenAddress, swapToTokenAddress);
            }
        });
        
        //create a new limit order
        createLimitOrder();
        // get order address from orderCreated emitted event
        // check new order attributes
       
    });
});

