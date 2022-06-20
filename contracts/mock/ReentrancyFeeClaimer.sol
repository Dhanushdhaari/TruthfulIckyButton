pragma solidity 0.6.6;

import "../IBerryNetworkProxy.sol";
import "../utils/Utils5.sol";
import "../IBerryFeeHandler.sol";

/// @dev contract to call trade when claimPlatformFee
contract ReentrancyFeeClaimer is Utils5 {
    IBerryNetworkProxy berryProxy;
    IBerryFeeHandler feeHandler;
    IERC20 token;
    uint256 amount;

    bool isReentrancy = true;

    constructor(
        IBerryNetworkProxy _berryProxy,
        IBerryFeeHandler _feeHandler,
        IERC20 _token,
        uint256 _amount
    ) public {
        berryProxy = _berryProxy;
        feeHandler = _feeHandler;
        token = _token;
        amount = _amount;
        require(_token.approve(address(_berryProxy), _amount));
    }

    function setReentrancy(bool _isReentrancy) external {
        isReentrancy = _isReentrancy;
    }

    receive() external payable {
        if (!isReentrancy) {
            return;
        }

        bytes memory hint;
        berryProxy.tradeWithHintAndFee(
            token,
            amount,
            ETH_TOKEN_ADDRESS,
            msg.sender,
            MAX_QTY,
            0,
            address(this),
            100,
            hint
        );
    }
}