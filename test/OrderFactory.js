const BigNumber = require("bignumber.js");
const NocturnalFinance = artifacts.require("./NocturnalFinance.sol");
const Noct = artifacts.require("./Noct.sol");
const NoctStaking = artifacts.require("./NoctStaking.sol");
const Oracle = artifacts.require("./Oracle.sol");
const Order = artifacts.require("./Order.sol");
const OrderFactory = artifacts.require("./OrderFactory.sol");
const Rewards = artifacts.require("./Rewards.sol");

contract('OrderFactory', accounts => {
    const owner = accounts[0];
    let NocturnalFinanceInstance;
    let NoctInstance;
    let NoctStakingInstance;
    let OracleInstance;
    let OrderInstance;
    let RewardsInstance;
    const testAddressCount = 3;  
    const depositRate = 200;  // 2% of fromToken (basis points)
    const rewardsFactor = 9000;  // 90% to creators, 10% to settlers (basis points)
    const swapPoolAddress = ""; // VE LINK/WETH pool address
    const swapFromTokenAddress = ""; // LINK address
    const swapToTokenAddress = ""; // WETH address
    const swapFromTokenBalance = ; // 100 tokens 
    const swapLimitPrice = ;  // not sure what the price tick data looks like yet
    const swapSlippage = 100; // 1% slippage (basis points)
    const swapAbove = true;
    const swapFromToken0 = true;
    const swapSettlementGratuity 100; // 1% of fromToken (basis points)
//=============================================================================================//    
//=============================================================================================//      
    
    async function call_createLimitOrder(
                _swapPoolAddress,
                _swapFromTokenAddress,
                _swapToTokenAddress,
                _swapFromTokenBalance,
                _swapLimitPrice,
                _swapSlippage,
                _swapAbove,
                _swapFromToken0,
                _swapSettlementGratuity) {
    	it("creates a new limit order", () => 
            OrderFactoryInstance.createLimitOrder(
            	_swapPoolAddress,
                _swapFromTokenAddress,
                _swapToTokenAddress,
                _swapFromTokenBalance,
                _swapLimitPrice,
                _swapSlippage,
                _swapAbove,
                _swapFromToken0,
                _swapSettlementGratuity)
        );
    };
    
    async function getOrderPoolAddress(orderAddress, expected_value) {
        let poolAddress;
        it("checks orderID", async () => {
            poolAddress = await OrderFactoryInstance.getOrderPoolAddress(orderAddress).call();
            assert.equal(poolAddress.words[0], expected_value);
        });
    };
    

//=============================================================================================//
//=============================================================================================//    

    before("setup", async () => {
        NocturnalFinanceInstance = await NocturnalFinance.deployed();
        NoctInstance = await Noct.deployed();
        NoctStakingInstance = await NoctStaking.deployed();
        RewardsInstance = await Rewards.deployed();
        OracleInstance = await Oracle.deployed();
        OrderInstance = await Order.deployed();
        OrderFactoryInstance = await OrderFactory.deployed();
    });

    describe("test with " + testAddressCount + " addresses", async () => {
        before("set depositRate and rewardsFactor to " + depositRate + " and " + rewardsFactor + " basis points, respectively", () => 
            NocturnalFinance.setDepositRate(depositRate);
            NocturnalFinance.setRewardsFactor(rewardsFactor);
        );

        before("seed addresses with WETH", async () => {
            );
        
        before("seed addresses with LINK", async () => {
            );
        
        //CREATE A NEW LIMIT ORDER WITH LINK/WETH POOL
        call_createLimitOrder(
    			swapPoolAddress,
    			swapFromTokenAddress,
    			swapToTokenAddress,
    			swapFromTokenBalance,
    			swapLimitPrice,
    			swapSlippage,
    			swapAbove,
    			swapFromToken0,
    			swapSettlementGratuity);
    	
    	// AFTER OBTAINING NEW ORDER ID ???
    	// CHECK ALL ORDER ATTRIBUTES
    	getOrderPoolAddress(swapPoolAddress);
    	
    	
    });
});

