pragma solidity 0.6.6;

import "../BerryNetwork.sol";


/*
 * @title Berry Network main contract that doesn't check max dest amount. so we can test it on proxy
 */
contract BerryNetworkNoMaxDest is BerryNetwork {
    constructor(address _admin, IBerryStorage _berryStorage)
        public
        BerryNetwork(_admin, _berryStorage)
    {}

    function calcTradeSrcAmountFromDest(TradeData memory tData)
        internal
        pure
        override
        returns (uint256 actualSrcAmount)
    {
        actualSrcAmount = tData.input.srcAmount;
    }
}