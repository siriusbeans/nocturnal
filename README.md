# nocturnal.finance

- all swaps are executed on Uniswap  
- supported uniswap pair pools are limited initially, but more are added over time  
- user sets the swap price limit(s) of the asset pair (also slippage ?)  
- user deposits assets to deposit pool contract  
- user is rewarded ERC20 NOCT tokens after they claim their swapped limit order assets     
- user can withdraw their assets in full from the contract at anytime, but will not receive NOCT rewards if withdrawn early  
- user's NOCT rewards are a function of the platform deposit fee and average gas price at time of deposit  
- user also earns NOCT when executing swap limit orders (settlement like BIOP) and when updating uniswap pair oracles (if necessary)   
- earned NOCT is a function of gas paid when executing swap limit orders (incentivize fast swapping) and oracle updates  
- when executing swap limit orders, a min gas price requirement is determined by Chainlink gas price feed (average or fast)  
- contracts are written so that events are emitted on-chain whenever an active swap limit order is ready for execution (for bot deployment)  
- fees are collected from users upon each asset deposit and each early asset deposit withdrawal  
- fees are distributed to NOCT burners  
- when a NOCT holder burns NOCT, they forever earn a percentage of the accumulated platform fees (similar to whiteheart staking)  
- the earned fees are equal to the % of their burned NOCT with respect to the total burned NOCT    
- fees are distributed to the NOCT burner addresses on every fee collecting event (real-time like whiteheart)  

# ideas for consideration

- allocate % of generated platform fees to NOCT burners  
- allocate % of generated platform fees to periodic lottery for NOCT holders  
- lottery drawing is held after specified amount of fees generated on platform  
- entire lotto jackpot distributed to single NOCT holder address (utilize Chainlink VRF)  
- incentives are designed to prevent NOCT supply from ballooning out of control due to no cap on total supply  
- cap the total supply, distribute tokens to team on deployment, and replace burn mechanisms with staking mechanisms (whiteheart)  
- allocate % of fees for chainlink token for VRF expenses and gas price feed expenses (if necessary)  

# current concerns

- no cap on NOCT total supply  
- NOCT is minted in only 2 possible ways  
  1) when trade is performed (NOCT rewarded to limit order creator and limit order caller)  
  2) when oracle is updated (NOCT rewarded to oracle update caller)  
- can truebit protocol be used to compute pickWinner functions?  
