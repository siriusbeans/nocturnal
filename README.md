# nocturnal.finance - a simple UI for decentralized swap limit orders  

-Swaps are executed on either Uniswap or Sushiswap as specified by the user  
-User specifies asset trading pair by contract addresses  
-User sets the swap limit(s) of the asset pair  
-User specifies preferred gas limit(s)  
-User deposits asset and receives an ERC721 in return  
-User is rewarded ERC20 NOCT tokens after trade is executed  
-User can monitor accumulated NOCT rewards while the assets are deposited  
-User can withdraw the asset in full from the contract at anytime, but will not receive NOCT rewards if the deposited assets are withdrawn early   
-User's NOCT rewards are a function of total deposited assets (in USDC at time of deposit) and total time deposited   
-Fees are collected from users upon each asset deposit, each trade execution, and each early trade withdrawal  
-A portion of the fees is collected for Chainlink price feed data (no premium)  
-A portion of the fees is collected for Ethereum transaction gas costs (no premium)  
-Users can earn rewards by staking NOCT  
-The remainder of all collected fees goes to NOCT stakers  
-Users can stake their NOCT through nocturnal.finance UI, and receive ERC20 sNOCT tokens in return
-An ERC721 is created and issued to a user after a swap limit order is created and the swap asset is deposited  
-The ERC721 records all user swap limit order information  
-After the user's swap limit order is executed, the ERC721 can be exchanged for the traded asset and any accumulated NOCT  
-The user's ERC721 can also be exchanged for the deposited assets prior to the swap limit order execution  
-If the ERC721 is exchanged for the deposited assets prior to the swap limit order execution, no accumulated NOCT is collected  
-The ERC721 is burned after it has been exchanged for the traded or deposited asset  
