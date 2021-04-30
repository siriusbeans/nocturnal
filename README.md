# nocturnal.finance - a simple UI for decentralized swap limit orders  

-Swaps are executed on either Uniswap or Sushiswap as specified by the user  
-User specifies asset trading pair by contract addresses  
-User sets the swap limit(s) of the asset pair  
-User specifies preferred gas limit(s) 
-User deposits asset and receives an ERC721 in exchange  
-User is rewarded ERC20 NOCT tokens after trade is executed  
-User can monitor accumulated NOCT rewards while assets are deposited  
-User can withdraw assets from contract at anytime, but will not receive NOCT rewards if assets are withdrawn early   
-User's NOCT rewards are a function of total deposited asset (in USDC at time of deposit) and total time deposited   
-Fees are collected from users upon each trade execution or upon each early trade withdrawal  
-A portion of the trading fees is collected for Chainlink price feed data (no premium)  
-A portion of the trading fees is collected for Ethereum transaction gas costs (no premium)  
-Users can earn rewards by staking NOCT  
-A portion of the trading fees goes to NOCT stakers  
-An ERC721 is created and issued to a user after a swap limit order is created and the swap asset is deposited  
-The ERC721 records all user swap limit order information  
-After the user's swap limit order is executed, the ERC721 can be exchanged for the traded asset and any accumulated NOCT  
-The user's ERC721 can also be exchanged for the deposited assets prior to the swap limit order execution  
-If the ERC721 is exchanged for the deposited assets prior to the swap limit order execution, no accumulated NOCT is collected  
-The ERC721 is burned after it has been exchanged for the traded or deposited asset  
