pragma solidity 0.6.6;

import "../BerryFeeHandler.sol";


contract MockContractCallBurnFib {
    BerryFeeHandler public feeHandler;

    constructor(BerryFeeHandler _feeHandler) public {
        feeHandler = _feeHandler;
    }

    function callBurnFib() public {
        feeHandler.burnFib();
    }
}