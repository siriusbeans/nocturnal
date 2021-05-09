# nocturnal.finance

- all swaps are executed on Uniswap  
- supported uniswap pair pools are limited initially, but more are added over time  
- user sets the swap price limit(s) of the asset pair (also slippage ?)  
- user deposits assets to deposit pool contract and receives an ERC721 in return  
- user is rewarded ERC20 NOCT tokens after swap limit order is executed and swapped asset is claimed   
- user can withdraw the asset in full from the contract at anytime, but will not receive NOCT rewards if the deposited assets are withdrawn early  
- user's NOCT rewards are a function of the platform deposit rate and average gas price (gwei) at time of deposit  
- user also earns NOCT when executing swap limit orders (settlement like BIOP) and when updating uniswap pair oracles (if necessary)   
- earned NOCT is a function of gas paid when executing swap limit orders (incentivize fast swapping) and oracle updates  
- when executing swap limit orders, a min gas price requirement is set and will equal the current Chainlink gas price feed (average-fast)  
- contracts are written so that events are emitted on-chain whenever an active swap limit order is ready for execution (for bot deployment)  
- fees are collected from users upon each asset deposit and each early asset deposit withdrawal  
- fees are distributed to NOCT burners  
- when a NOCT holder burns NOCT, they forever earn a percentage of the accumulated platform fees (similar to whiteheart staking)  
- the earned fees are equal to the % of their burned NOCT with respect to the total burned NOCT    
- fees are distributed to the NOCT burner addresses on every fee collecting event (real-time like whiteheart)  
- the ERC721 received after deposit records all user swap limit order information  
- the information recorded by the ERC721 is the swap pair address, pair token amount, and pair token swap price target(s)  
- after the user's swap limit order is executed, the ERC721 can be exchanged for the traded assets and the associated NOCT rewards  
- the user's ERC721 can also be exchanged for the deposited assets prior to the swap limit order execution (without NOCT rewards)    
- the swap deposit ERC721 is burned after it has been exchanged for the traded or deposited asset  

# ideas for consideration

- allocate % of generated platform fees to NOCT burners  
- allocate % of generated platform fees to periodic lottery  
- lottery drawing is held after specified amount of fees generated on platform  
- entire lotto jackpot distributed to single NOCT holder address (utilize Chainlink VRF)  
- incentives are designed to prevent NOCT supply from ballooning out of control due to no cap on total supply  
- utilize truebit protocol for off chain jackpot winner contract execution  
- cap the total supply, distribute tokens to team on deployment, and replace burn mechanisms with staking mechanisms (whiteheart)  
- allocate % of fees for chainlink token for VRF expenses and gas price feed expenses (if necessary)  

# current concerns

- no cap on NOCT total supply  
- NOCT is minted in only 2 possible ways  
  1) when trade is performed (NOCT rewarded to limit order creator and limit order caller)  
  2) when oracle is updated (NOCT rewarded to oracle update caller)  
- can truebit protocol be used to call pickWinner contract?  
