# nocturnal.finance - a simple interface for incentivized sell limit orders

-Swaps are executed on either Uniswap or Sushiswap as specified by the user  
-User specifies asset trading pair by contract addresses  
-User sets sell stop limit of asset  
-User specifies preferred gas limit  
-User deposits asset  
-User is rewarded NOCT tokens after trade is executed  
-User can monitor accumulated NOCT rewards while assets are deposited  
-User can withdraw assets from contract at anytime, but will not receive NOCT rewards if assets are withdrawn  
-User's NOCT rewards are a function of total deposited asset (in USD at time of deposit) and total time deposited  
-Users can earn rewards by staking NOCT  
-Fees are collected from users upon each trade execution or upon each early trade withdrawal  
-A portion of the trading fees is collected for Chainlink price feed data (no premium)  
-A portion of the trading fees is collected for Ethereum transaction gas costs (no premium)  
-A portion of the trading fees goes to NOCT stakers  
