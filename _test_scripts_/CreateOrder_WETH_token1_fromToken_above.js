const BigNumber = require("bignumber.js");
const NocturnalFinance = artifacts.require("./NocturnalFinance.sol");
const Noct = artifacts.require("./Noct.sol");
const NoctStaking = artifacts.require("./NoctStaking.sol");
const Oracle = artifacts.require("./Oracle.sol");
const Order = artifacts.require("./Order.sol");
const CreateOrder = artifacts.require("./CreateOrder.sol");
const DepositOrder = artifacts.require("./DepositOrder.sol");
const SettleOrder = artifacts.require("./SettleOrder.sol");
const CloseOrder = artifacts.require("./CloseOrder.sol");
const Rewards = artifacts.require("./Rewards.sol");
const Treasury = artifacts.require("./Treasury.sol");
const TokenMinter = artifacts.require("./Mocks/TokenMinter.sol");
const TokenSwapper = artifacts.require("./Mocks/TokenSwapper.sol");
const SettleOrderTransfer = artifacts.require("./SettleOrderTransfer.sol");
const DistributeRewards = artifacts.require("./DistributeRewards.sol");
var WethToken = artifacts.require("WethToken");
var LinkToken = artifacts.require("LinkToken");
//var _Order = artifacts.require(_Order); // use to ensure no functions can be called on the new order nefariously
//let orderAddress = await CreateOrderInstance._orders(orderID).orderAddress; // address of new order
//const _OrderInstance = await _Order.at(OrderAddress); // instance of new order address (call functions from this)

contract('CreateOrder_WETH_token1_fromToken_above', accounts => {
    const owner = accounts[0];
    let NocturnalFinanceInstance;
    let NoctInstance;
    let NoctStakingInstance;
    let OracleInstance;
    let OrderInstance;
    let CreateOrderInstance;
    let DepositOrderInstance;
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
    const WETH = "0x84fff9F8Bec0835494C4c9f43cfe32C7d37F82b5";
    const LINK = "0x27E1A4409fa79E5380aDE99ED289DBF342613Ce6";
    const fromTokenAddress = WETH; // WETH address
    const toTokenAddress = LINK; // LINK address
    const fromTokenBalance1 = toWei(100); // 100 tokens in wei
    const fromTokenBalance2 = toWei(50); // 50 tokens in wei
    const amountOutMin1 = toWei(0); // calculate appropriate amountOutMin
    const amountOutMin2 = toWei(0); // calculate appropriate amountOutMin
    const limitPrice = toWei(1);  // price in wei
    const settlementGratuity = toWei(5); // gratuity (in WETH) that will be provided to settler
    
//=============================================================================================//    
//=============================================================================================//      

    async function createOrder(orderAmount, type, outMin, fromAccount) {
    	it("creates a new order", async () => {
            await CreateOrderInstance.createOrder(
            	[poolAddress,
                fromTokenAddress,
                toTokenAddress,
                orderAmount,
                limitPrice,
                type,
                outMin,
                settlementGratuity], 
                { from: fromAccount }
            );  
        });
    };   
    
    async function check_orderAttributes(orderID, fromAccount) {
        let attributes;
        it("checks order attributes", async () => {  
            attributes = await CreateOrderInstance._orders(orderID, { from: fromAccount });
            console.log("         order",orderID,"attributes","\n",
                        "         orderAddress:",attributes.orderAddress,"\n",
                        "         poolAddress:",attributes.poolAddress,"\n",
                        "         fromTokenAddress:",attributes.fromTokenAddress,"\n",
                        "         toTokenAddress:",attributes.toTokenAddress,"\n",
                        "         tokenBalance:",attributes.tokenBalance.words,"\n",
                        "         limitPrice:",attributes.limitPrice.words,"\n",
                        "         limitType:",attributes.limitType,"\n",
                        "         amountOutMin:",attributes.amountOutMin.words,"\n",
                        "         settlementGratuity:",attributes.settlementGratuity.words,"\n",
                        "         depositedFlag:",attributes.depositedFlag,"\n",
                        "         settledFlag:",attributes.settledFlag,"\n",
                        "         closedFlag:",attributes.closedFlag);
        });
    };
    
    async function checkPoolPrice(orderID, fromAccount) {
        let attributes;
        let poolAddress;
        let poolPrice;
        it("checks order attributes", async () => {  
            attributes = await CreateOrderInstance._orders(orderID, { from: fromAccount });
            let poolAddress = attributes.poolAddress;
            let poolPrice = await OracleInstance.getCurrentPrice(poolAddress);
            console.log("         order",orderID,"pool price =",poolPrice.words);
        });
    };

    async function approveDeposit(token, balance, fromAccount) {
    	it("approves DepositOrder.sol to transfer to order", async () => {
    	    if (token === LINK) {
    	        const LinkInstance = await LinkToken.at(LINK);
                await LinkInstance.approve(DepositOrderInstance.address, balance, { from: fromAccount });
            } else if (token === WETH) {
                const WethInstance = await WethToken.at(WETH);        
                await WethInstance.approve(DepositOrderInstance.address, balance, { from: fromAccount });
            }
        });
    };   
    
    async function approveSettle(token, balance, fromAccount) {
    	it("approves SettleOrderTransfer.sol to transfer to order", async () => {
    	    if (token === LINK) {
    	        const LinkInstance = await LinkToken.at(LINK);
                await LinkInstance.approve(SettleOrderTransferInstance.address, balance, { from: fromAccount });
            } else if (token === WETH) {
                const WethInstance = await WethToken.at(WETH);        
                await WethInstance.approve(SettleOrderTransferInstance.address, balance, { from: fromAccount });
            }
        });
    };  
    
    async function balanceOfAccount(token, account, fromAccount) {
        it("gets account's balance of token", async () => {
    	    if (token === LINK) {
    	        const LinkInstance = await LinkToken.at(LINK);
                let balance = await LinkInstance.balanceOf(account, { from: fromAccount });
                console.log("         account balance =",balance.words);
            } else if (token === WETH) {
                const WethInstance = await WethToken.at(WETH);        
                let balance = await WethInstance.balanceOf(account, { from: fromAccount });
                console.log("         account balance =",balance.words);
            } else if (token == NoctInstance.address) {
                let balance = await NoctInstance.balanceOf(account, { from: fromAccount });
                console.log("         account balance =",balance.words);
            }
        });
    };
    
    async function depositOrder(orderID, fromAccount) {
    	it("deposits tokenBalance to order", async () => {
            await CreateOrderInstance.depositOrder(orderID, { from: fromAccount });
        });
    };   
    
    async function closeOrder(orderID, fromAccount) {
    	it("closes an order", async () => {
            await CreateOrderInstance.closeOrder(orderID, { from: fromAccount });
        });
    }; 
    
    async function settleOrder(orderID, fromAccount) {
    	it("settles an order", async () => {
            await CreateOrderInstance.settleOrder(orderID, { from: fromAccount });
        });
    }; 
    
    async function transferOrder(from, to, orderID, fromAccount) {
    	it("transfers orderID", async () => {
            await OrderInstance.transferFrom(from, to, orderID, { from: fromAccount });
        });
    }; 
    
    async function orderOwner(orderID, fromAccount) {
        it("checks owner of orderID", async () => {
            let owner = await OrderInstance.ownerOf(orderID, { from: fromAccount });
            console.log("         order owner =",owner);
        });
    };
    
    async function swap(tokenIn, tokenOut, amountIn, fromAccount) {
        it("performs swap", async () => {
            if (tokenIn === LINK) {
    	        const LinkInstance = await LinkToken.at(LINK);
                await LinkInstance.approve(TokenSwapperInstance.address, amountIn, { from: fromAccount });
            } else if (tokenIn === WETH) {
                const WethInstance = await WethToken.at(WETH);        
                await WethInstance.approve(TokenSwapperInstance.address, amountIn, { from: fromAccount });
            }
            let amountOut = await TokenSwapperInstance.getExactInputSingle(tokenIn, tokenOut, amountIn, { from: fromAccount });
            //console.log("         received =",amountOut);
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
        SettleOrderTransferInstance = await SettleOrderTransfer.deployed();
    	CreateOrderInstance = await CreateOrder.deployed();
    	SettleOrderInstance = await SettleOrder.deployed();
    	DepositOrderInstance = await DepositOrder.deployed();
    	CloseOrderInstance = await CloseOrder.deployed();
    	RewardsInstance = await Rewards.deployed();
    	TokenMinterInstance = await TokenMinter.deployed();
    	TokenSwapperInstance = await TokenSwapper.deployed();
    	DistributeRewardsInstance = await DistributeRewards.deployed();
    	
    	NocturnalFinanceInstance.setPlatformRate(depositRate);
    	NocturnalFinanceInstance.setTreasuryFactor(treasuryFactor);
    	NocturnalFinanceInstance.setRewardsFactor(rewardsFactor);
        NocturnalFinanceInstance.setOrderURI(orderURI);
        
        for (let i = 0; i < accounts.length-1; i++) {
            await TokenMinterInstance.mintTokens(fromTokenAddress, toTokenAddress, { from: accounts[i]});
        }   
    });

    describe("tests new order creation", async () => {

        // create a new order
        createOrder(fromTokenBalance1, true, amountOutMin1, accounts[0]);
        
        // check order attributes
        check_orderAttributes(1, accounts[0]);
        
        // create a new order
        //createOrder(fromTokenBalance2, false, amountOutMin2, accounts[0]);
        
        // check order attributes
        //check_orderAttributes(2, accounts[0]); 
        
        // check address balance
        //balanceOfAccount(WETH, accounts[0], accounts[0]);
        
        // approve DepositOrder.sol allowance
        approveDeposit(fromTokenAddress, fromTokenBalance1, accounts[1]);

        // deposit to order
        depositOrder(1, accounts[1]);
        
        // check order attributes
        check_orderAttributes(1, accounts[0]);  
        
        // check order owner balance
        //balanceOfAccount(WETH, accounts[0], accounts[0]);
        
        // close order
        //closeOrder(1, accounts[0]);
        
        // check order owner balance
        //balanceOfAccount(WETH, accounts[0], accounts[0]);
        
        // check order attributes
        //check_orderAttributes(1, accounts[0]); 
        
        // check order attributes
        //check_orderAttributes(2, accounts[0]); 
        
        // check order owner address
        //orderOwner(2, accounts[0]);
        
        // transfer order 
        //transferOrder(accounts[0], accounts[1], 2, accounts[0]);  
        
        // check order owner address
        //orderOwner(2, accounts[0]);
        
        // check address balance
        //balanceOfAccount(WETH, accounts[0], accounts[0]);
        
        // approve DepositOrder.sol allowance
        //approveDeposit(fromTokenAddress, fromTokenBalance2, accounts[0]);
        
        // deposit to order
        //depositOrder(2, accounts[0]);
        
        // check order attributes
        //check_orderAttributes(2, accounts[0]);  
        
        // check order owner balance
        //balanceOfAccount(WETH, accounts[1], accounts[0]);
        
        // close order
        //closeOrder(2, accounts[1]);
        
        // check order owner balance
        //balanceOfAccount(WETH, accounts[1], accounts[0]);
        
        // check order attributes
        //check_orderAttributes(2, accounts[0]); 
        
        // =============== AT THIS POINT ============= //
        // created multiple orders                     //
        // deposited to multiple orders                //
        // transfered orderID to multiple accounts     //
        // verified only orderID owner can close order //
        // =========================================== //
        
        // check pool price
        //checkPoolPrice(1, accounts[0]);

        // perform swaps to manipulate pool price, as needed
        swap(WETH, LINK, toWei(100), accounts[0]);
        swap(WETH, LINK, toWei(100), accounts[0]);
        swap(WETH, LINK, toWei(100), accounts[0]);
        
        // check pool price
        //checkPoolPrice(1, accounts[0]);
        
        // settle order 1 from accounts[1]
        settleOrder(1, accounts[2]);
        
        // check order attributes
        check_orderAttributes(1, accounts[0]);  
        
        // settle order 1 from accounts[1]
        //settleOrder(2, accounts[0]);
        
        // check order attributes
        //check_orderAttributes(2, accounts[0]);  
        
        // close order
        closeOrder(1, accounts[0]);
        
        // check order attributes
        check_orderAttributes(1, accounts[0]);  
        
    });
});
