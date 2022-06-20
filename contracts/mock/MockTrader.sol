pragma solidity 0.6.6;

import "../IBerryNetworkProxy.sol";


contract MockTrader {
    IERC20 internal constant ETH_TOKEN_ADDRESS = IERC20(
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    );
    IBerryNetworkProxy public berryNetworkProxy;

    constructor(IBerryNetworkProxy _berryNetworkProxy) public {
        berryNetworkProxy = _berryNetworkProxy;
    }

    function tradeWithHintAndFee(
        IERC20 src,
        uint256 srcAmount,
        IERC20 dest,
        address payable destAddress,
        address payable platformWallet,
        uint256 platformFeeBps,
        bytes calldata hint
    ) external payable returns (uint256 destAmount) {
        if (src != ETH_TOKEN_ADDRESS) {
            require(src.transferFrom(msg.sender, address(this), srcAmount));
            require(src.approve(address(berryNetworkProxy), srcAmount));
        }

        uint256 rate = berryNetworkProxy.getExpectedRateAfterFee(
            src,
            dest,
            srcAmount,
            platformFeeBps,
            hint
        );

        return
            berryNetworkProxy.tradeWithHintAndFee{value: msg.value}(
                src,
                srcAmount,
                dest,
                destAddress,
                2**255,
                rate,
                platformWallet,
                platformFeeBps,
                hint
            );
    }
}