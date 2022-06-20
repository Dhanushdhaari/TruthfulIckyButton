pragma solidity 0.6.6;

import "../BerryNetwork.sol";


// override some of original BerryNetwork contract
contract MockNetwork is BerryNetwork {
    constructor(address _admin, IBerryStorage _berryStorage)
        public
        BerryNetwork(_admin, _berryStorage)
    {}

    // allow set zero contract
    function setContracts(
        IBerryFeeHandler _berryFeeHandler,
        IBerryMatchingEngine _berryMatchingEngine,
        IGasHelper _gasHelper
    ) external override {
        if (berryFeeHandler != _berryFeeHandler) {
            berryFeeHandler = _berryFeeHandler;
            emit BerryFeeHandlerUpdated(_berryFeeHandler);
        }

        if (berryMatchingEngine != _berryMatchingEngine) {
            berryMatchingEngine = _berryMatchingEngine;
            emit BerryMatchingEngineUpdated(_berryMatchingEngine);
        }

        if ((_gasHelper != IGasHelper(0)) && (_gasHelper != gasHelper)) {
            gasHelper = _gasHelper;
            emit GasHelperUpdated(_gasHelper);
        }
    }

    function mockHandleChange(
        IERC20 src,
        uint256 srcAmount,
        uint256 requiredSrcAmount,
        address payable trader
    ) public {
        return handleChange(src, srcAmount, requiredSrcAmount, trader);
    }

    function setNetworkFeeData(uint256 _networkFeeBps, uint256 _expiryTimestamp) public {
        updateNetworkFee(_expiryTimestamp, _networkFeeBps);
    }

    function getNetworkFeeData()
        public
        view
        returns (uint256 _networkFeeBps, uint256 _expiryTimestamp)
    {
        (_networkFeeBps, _expiryTimestamp) = readNetworkFeeData();
    }

    function mockGetNetworkFee() public view returns (uint256 networkFeeBps) {
        return getNetworkFee();
    }

    //over ride some functions to reduce contract size.
    function doReserveTrades(
        IERC20 src,
        IERC20 dest,
        address payable destAddress,
        ReservesData memory reservesData,
        uint256 expectedDestAmount,
        uint256 srcDecimals,
        uint256 destDecimals
    ) internal override {
        src;
        dest;
        destAddress;
        reservesData;
        expectedDestAmount;
        srcDecimals;
        destDecimals;

        revert("must use real network");
        // return true;
    }
}