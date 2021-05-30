/*                              $$\                                             $$\                                                         
                                $$ |                                            $$ |                                                  
$$$$$$$\   $$$$$$\   $$$$$$$\ $$$$$$\   $$\   $$\  $$$$$$\  $$$$$$$\   $$$$$$\  $$ |     
$$  __$$\ $$  __$$\ $$  _____|\_$$  _|  $$ |  $$ |$$  __$$\ $$  __$$\  \____$$\ $$ |    
$$ |  $$ |$$ /  $$ |$$ /        $$ |    $$ |  $$ |$$ |  \__|$$ |  $$ | $$$$$$$ |$$ |     
$$ |  $$ |$$ |  $$ |$$ |        $$ |$$\ $$ |  $$ |$$ |      $$ |  $$ |$$  __$$ |$$ |     
$$ |  $$ |\$$$$$$  |\$$$$$$$\   \$$$$  |\$$$$$$  |$$ |      $$ |  $$ |\$$$$$$$ |$$ |      
\__|  \__| \______/  \_______|   \____/  \______/ \__|      \__|  \__| \_______|\__|     
*/

pragma solidity ^0.8.0;
pragma abicoder v2;

interface CreateOrderInterface {

    struct Attributes {
        address orderAddress;
        address poolAddress;
        address fromTokenAddress;
        address toTokenAddress;
        uint256 tokenBalance;
        uint256 fromTokenValueInETH;
        uint256 limitPrice;
        bool limitType;
        uint24 slippage;
        uint24 settlementGratuity;
        bool depositedFlag;
        bool settledFlag;
    }

    struct CreateParams {
        address poolAddress;
        address fromTokenAddress;
        address toTokenAddress;
        uint256 tokenBalance;
        uint256 limitPrice;
        uint24 slippage;
        bool limitType;
        uint24 settlementGratuity;
    }
    
    struct DepositParams {
        address orderAddress;
        address poolAddress;
        address fromTokenAddress;
        uint256 tokenBalance;
        bool depositedFlag;
    }
    
    struct SettleParams {
        address orderAddress;
        address poolAddress;
        address fromTokenAddress;
        uint256 tokenBalance;
        uint256 fromTokenValueInETH;
        uint256 limitPrice;
        bool limitType;
        uint24 slippage;
        uint24 settlementGratuity;
        bool depositedFlag;
        bool settledFlag;
    }
    
    struct CloseParams {
        address orderAddress;
        address poolAddress;
        address fromTokenAddress;
        address toTokenAddress;
        uint256 tokenBalance;
        uint24 slippage;
        bool depositedFlag;
        bool settledFlag;
    }
    
    function createOrder(CreateParams calldata params) external;
    function depositOrder(uint256) external;
    function settleOrder(uint256) external;
    function closeOrder(uint256) external;
   
    function orderAttributes(uint256) external view 
        returns (address, address, address, address, uint256, uint256, uint256, bool, uint24, uint24, bool, bool); 
        
    function setAttributes(uint256, uint256) external; 


}
