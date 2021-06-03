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

contract('CreateOrder_LINK_token0_fromToken_above', accounts => {
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
    const platformRate = 500;  // 5% of fromToken (basis points)
    const treasuryFactor = 2000; // 20% of order rewards to treasury (basis points)
    const rewardsFactor = 8000;  // 80% of (order rewards - treasury rewards) to creators, 20% to settlers (basis points)
    const poolAddress = "0xEa9ab84751A2ef0db5f3601aE8EC0F1E4798728B"; // LINK/WETH pool address
    const WETH = "0x84fff9F8Bec0835494C4c9f43cfe32C7d37F82b5";
    const LINK = "0x27E1A4409fa79E5380aDE99ED289DBF342613Ce6";
    const fromTokenAddress = WETH; 
    const toTokenAddress = LINK; 
    const fromTokenBalance = toWei(10); // 100 tokens in wei
    const amountOutMin = toWei(0); // calculate appropriate amountOutMin
    const limitPrice = toWei(1);  // price in wei
    const settlementGratuity = toWei(1); // gratuity (in WETH) that will be provided to settler
    
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
                        "         tokenBalance:",attributes.tokenBalance.toString(),"\n",
                        "         limitPrice:",attributes.limitPrice.toString(),"\n",
                        "         limitType:",attributes.limitType,"\n",
                        "         amountOutMin:",attributes.amountOutMin.toString(),"\n",
                        "         settlementGratuity:",attributes.settlementGratuity.toString(),"\n",
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
            console.log("         order",orderID,"pool price =",poolPrice.toString());
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
        it("returns an account's token balance", async () => {
    	    if (token === LINK) {
    	        const LinkInstance = await LinkToken.at(LINK);
                let balance = await LinkInstance.balanceOf(account, { from: fromAccount });
                console.log("         account balance =",balance.toString());
            } else if (token === WETH) {
                const WethInstance = await WethToken.at(WETH);        
                let balance = await WethInstance.balanceOf(account, { from: fromAccount });
                console.log("         account balance =",balance.toString());
            } else if (token == NoctInstance.address) {
                let balance = await NoctInstance.balanceOf(account, { from: fromAccount });
                console.log("         account balance =",balance.toString());
            }
        });
    };
    
    async function returnNoctBalances(owner, settler, fromAccount) {
        it("returns NOCT account balances", async () => {
            let ownerBalance = await RewardsInstance.unclaimedRewards(owner, { from: fromAccount });
            console.log("         owner NOCT balance =",ownerBalance.toString());
            let settlerBalance = await RewardsInstance.unclaimedRewards(settler, { from: fromAccount });
            console.log("         settler NOCT balance =",settlerBalance.toString());
            let treasuryBalance = await RewardsInstance.unclaimedRewards(TreasuryInstance.address, { from: fromAccount });
            console.log("         treasury NOCT balance =",treasuryBalance.toString());
        });
    };
    
    async function returnWethBalances(settler, fromAccount) {
        it("returns WETH account balances", async () => {
            const WethInstance = await WethToken.at(WETH);        
            let settlerBalance = await WethInstance.balanceOf(settler, { from: fromAccount });
            console.log("         settler WETH balance =",settlerBalance.toString());
            let stakersBalance = await WethInstance.balanceOf(NoctStakingInstance.address, { from: fromAccount });
            console.log("         stakers WETH balance =",stakersBalance.toString());
        });
        
    }
    
    async function returnEthBalances(settler) {
        it("returns ETH account balances", async () => {
            let settlerBalance = await web3.eth.getBalance(settler);
            console.log("         settler ETH balance =",settlerBalance);
            let stakersBalance = await web3.eth.getBalance(NoctStakingInstance.address);
            console.log("         stakers ETH balance =",stakersBalance);
        });
    }
    
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
    	
    	NocturnalFinanceInstance.setPlatformRate(platformRate);
    	NocturnalFinanceInstance.setTreasuryFactor(treasuryFactor);
    	NocturnalFinanceInstance.setRewardsFactor(rewardsFactor);
        NocturnalFinanceInstance.setOrderURI(orderURI);
        
        for (let i = 0; i < accounts.length-1; i++) {
            await TokenMinterInstance.mintTokens(fromTokenAddress, toTokenAddress, { from: accounts[i]});
        }   
    });

    describe("tests new order creation, deposit, settlement, closure, and staking", async () => {

        // create a new order
        createOrder(fromTokenBalance, true, amountOutMin, accounts[0]);
        
        // create a new order
        createOrder(fromTokenBalance, true, amountOutMin, accounts[0]);
        
        // create a new order
        createOrder(fromTokenBalance, true, amountOutMin, accounts[0]);
        
        // create a new order
        createOrder(fromTokenBalance, true, amountOutMin, accounts[0]);
        
        // create a new order
        createOrder(fromTokenBalance, true, amountOutMin, accounts[0]);
        
        // create a new order
        createOrder(fromTokenBalance, true, amountOutMin, accounts[0]);
        
        // create a new order
        createOrder(fromTokenBalance, true, amountOutMin, accounts[0]);
        
        // create a new order
        createOrder(fromTokenBalance, true, amountOutMin, accounts[0]);
        
        // create a new order
        createOrder(fromTokenBalance, true, amountOutMin, accounts[0]);
        
        // create a new order
        createOrder(fromTokenBalance, true, amountOutMin, accounts[0]);

        
        

        // approve DepositOrder.sol allowance
        approveDeposit(fromTokenAddress, fromTokenBalance, accounts[0]);
        
        // deposit to order
        depositOrder(1, accounts[0]);
        
        // approve DepositOrder.sol allowance
        approveDeposit(fromTokenAddress, fromTokenBalance, accounts[0]);
        
        // deposit to order
        depositOrder(2, accounts[0]);
        
        // approve DepositOrder.sol allowance
        approveDeposit(fromTokenAddress, fromTokenBalance, accounts[0]);
        
        // deposit to order
        depositOrder(3, accounts[0]);
        
        // approve DepositOrder.sol allowance
        approveDeposit(fromTokenAddress, fromTokenBalance, accounts[0]);
        
        // deposit to order
        depositOrder(4, accounts[0]);
        
        // approve DepositOrder.sol allowance
        approveDeposit(fromTokenAddress, fromTokenBalance, accounts[0]);
        
        // deposit to order
        depositOrder(5, accounts[0]);
        
        // approve DepositOrder.sol allowance
        approveDeposit(fromTokenAddress, fromTokenBalance, accounts[0]);
        
        // deposit to order
        depositOrder(6, accounts[0]);
        
        // approve DepositOrder.sol allowance
        approveDeposit(fromTokenAddress, fromTokenBalance, accounts[0]);
        
        // deposit to order
        depositOrder(7, accounts[0]);
        
        // approve DepositOrder.sol allowance
        approveDeposit(fromTokenAddress, fromTokenBalance, accounts[0]);
        
        // deposit to order
        depositOrder(8, accounts[0]);
        
        // approve DepositOrder.sol allowance
        approveDeposit(fromTokenAddress, fromTokenBalance, accounts[0]);
        
        // deposit to order
        depositOrder(9, accounts[0]);
        
        // approve DepositOrder.sol allowance
        approveDeposit(fromTokenAddress, fromTokenBalance, accounts[0]);
        
        // deposit to order
        depositOrder(10, accounts[0]);
        
        

        // perform swaps to manipulate pool price, as needed
        swap(WETH, LINK, toWei(100), accounts[3]);
        swap(WETH, LINK, toWei(100), accounts[3]);
        swap(WETH, LINK, toWei(100), accounts[3]);



        // check WETH balances
        returnWethBalances(accounts[1], accounts[0]);
        
        // check NOCT balances
        returnNoctBalances(accounts[0], accounts[1], accounts[0]);
  
  
  
        // settle order 1 from accounts[1]
        settleOrder(1, accounts[1]);
        
        // perform swaps to manipulate pool price, as needed
        swap(WETH, LINK, toWei(100), accounts[3]);
        
        // check WETH balances
        returnWethBalances(accounts[1], accounts[0]);
        
        // check NOCT balances
        returnNoctBalances(accounts[0], accounts[1], accounts[0]);
        
       
       
        // settle order 1 from accounts[1]
        settleOrder(2, accounts[1]);
  
        // perform swaps to manipulate pool price, as needed
        swap(WETH, LINK, toWei(100), accounts[3]);
        
        // check WETH balances
        returnWethBalances(accounts[1], accounts[0]);
        
        // check NOCT balances
        returnNoctBalances(accounts[0], accounts[1], accounts[0]);
        
        
        
        // settle order 1 from accounts[1]
        settleOrder(3, accounts[1]);

        // perform swaps to manipulate pool price, as needed
        swap(WETH, LINK, toWei(100), accounts[3]);
        
        // check WETH balances
        returnWethBalances(accounts[1], accounts[0]);
        
        // check NOCT balances
        returnNoctBalances(accounts[0], accounts[1], accounts[0]);
        
        
        
        // settle order 1 from accounts[1]
        settleOrder(4, accounts[1]);
        
        // perform swaps to manipulate pool price, as needed
        swap(WETH, LINK, toWei(100), accounts[3]);

        // check WETH balances
        returnWethBalances(accounts[1], accounts[0]);
        
        // check NOCT balances
        returnNoctBalances(accounts[0], accounts[1], accounts[0]);
        
        
        
        // settle order 1 from accounts[1]
        settleOrder(5, accounts[1]);
        
        // perform swaps to manipulate pool price, as needed
        swap(WETH, LINK, toWei(100), accounts[3]);
        
        // check WETH balances
        returnWethBalances(accounts[1], accounts[0]);
        
        // check NOCT balances
        returnNoctBalances(accounts[0], accounts[1], accounts[0]);
        
       
       
        // settle order 1 from accounts[1]
        settleOrder(6, accounts[1]);
  
        // perform swaps to manipulate pool price, as needed
        swap(WETH, LINK, toWei(100), accounts[3]);
        
        // check WETH balances
        returnWethBalances(accounts[1], accounts[0]);
        
        // check NOCT balances
        returnNoctBalances(accounts[0], accounts[1], accounts[0]);
        
        
        
        // settle order 1 from accounts[1]
        settleOrder(7, accounts[1]);

        // perform swaps to manipulate pool price, as needed
        swap(WETH, LINK, toWei(100), accounts[3]);
        
        // check WETH balances
        returnWethBalances(accounts[1], accounts[0]);
        
        // check NOCT balances
        returnNoctBalances(accounts[0], accounts[1], accounts[0]);
        
        
        
        // settle order 1 from accounts[1]
        settleOrder(8, accounts[1]);
        
        // perform swaps to manipulate pool price, as needed
        swap(WETH, LINK, toWei(100), accounts[3]);

        // check WETH balances
        returnWethBalances(accounts[1], accounts[0]);
        
        // check NOCT balances
        returnNoctBalances(accounts[0], accounts[1], accounts[0]);
        
        
        
        // settle order 1 from accounts[1]
        settleOrder(9, accounts[1]);

        // perform swaps to manipulate pool price, as needed
        swap(WETH, LINK, toWei(100), accounts[3]);
        
        // check WETH balances
        returnWethBalances(accounts[1], accounts[0]);
        
        // check NOCT balances
        returnNoctBalances(accounts[0], accounts[1], accounts[0]);
        
        
        
        // settle order 1 from accounts[1]
        settleOrder(10, accounts[1]);
        
        // perform swaps to manipulate pool price, as needed
        swap(WETH, LINK, toWei(100), accounts[3]);

        // check WETH balances
        returnWethBalances(accounts[1], accounts[0]);
        
        // check NOCT balances
        returnNoctBalances(accounts[0], accounts[1], accounts[0]);
        
        
        
        
        // close order
        closeOrder(1, accounts[0]);
        
        // close order
        closeOrder(2, accounts[0]);
        
        // close order
        closeOrder(3, accounts[0]);
        
        // close order
        closeOrder(4, accounts[0]);
        
        // close order
        closeOrder(5, accounts[0]);
        
        // close order
        closeOrder(6, accounts[0]);
        
        // close order
        closeOrder(7, accounts[0]);
        
        // close order
        closeOrder(8, accounts[0]);
        
        // close order
        closeOrder(9, accounts[0]);
        
        // close order
        closeOrder(10, accounts[0]);


    });
});
