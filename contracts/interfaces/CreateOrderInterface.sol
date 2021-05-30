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
        uint256 slippage;
        uint256 settlementGratuity;
        bool depositedFlag;
        bool settledFlag;
    }

    struct CreateParams {
        address poolAddress;
        address fromTokenAddress;
        address toTokenAddress;
        uint256 tokenBalance;
        uint256 limitPrice;
        uint256 slippage;
        bool limitType;
        uint256 settlementGratuity;
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
        uint256 slippage;
        uint256 settlementGratuity;
        bool depositedFlag;
        bool settledFlag;
    }
    
    struct CloseParams {
        address orderAddress;
        address poolAddress;
        address fromTokenAddress;
        address toTokenAddress;
        uint256 tokenBalance;
        uint256 slippage;
        bool depositedFlag;
        bool settledFlag;
    }
    
    function createOrder(CreateParams calldata params) external;
    
    function depositOrder(uint256) external;
    
    function settleOrder(uint256) external;
    
    function closeOrder(uint256) external;

    function modifyOrderSlippage(uint256, uint256) external;
    
    function modifyOrderSettlementGratuity(uint256, uint256) external;

    function orderAttributes(uint256) external view 
        returns (address, address, address, address, uint256, uint256, uint256, bool, uint256, uint256, bool, bool);

    function setTokenBalance(uint256, uint256) external;
    function setFromTokenValueInETH(uint256, uint256) external;
    function setDepositedFlag(uint256, bool) external;
    function setSettledFlag(uint256, bool) external;
    function setSlippage(uint256, uint256) external;
    function setSettlementGratuity(uint256, uint256) external;

}
