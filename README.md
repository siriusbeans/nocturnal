# nocturnal.finance - a simple UI for decentralized swap limit orders  

-Swaps are executed on either Uniswap or Sushiswap as specified by the user  
-User specifies asset trading pair by contract addresses  
-User sets swap limit of asset  
-User specifies preferred gas limit  
-User deposits asset  
-User is rewarded NOCT tokens after trade is executed  
-User can monitor accumulated NOCT rewards while assets are deposited  
-User can withdraw assets from contract at anytime, but will not receive NOCT rewards if assets are withdrawn early   
-User's NOCT rewards are a function of total deposited asset (in USDC at time of deposit) and total time deposited   
-Fees are collected from users upon each trade execution or upon each early trade withdrawal  
-A portion of the trading fees is collected for Chainlink price feed data (no premium)  
-A portion of the trading fees is collected for Ethereum transaction gas costs (no premium)  
-Users can earn rewards by staking NOCT  
-A portion of the trading fees goes to NOCT stakers  
-An ERC721 is created and issued to user when swap limit order is filled  
-The ERC721 records all user swap limit order information  
-After the users swap limit order is filled the ERC721 is exchanged for the traded asset or early withdrawn asset  
-The ERC721 is burned after it has been exchanged for a traded or deposited asset  
