pragma solidity 0.6.6;

import "../../IBerryFeeHandler.sol";


contract MockStakerClaimRewardReentrancy {
    IBerryFeeHandler public feeHandler;
    bool public isTestingReentrant = true;

    constructor(
        IBerryFeeHandler _feeHandler
    )
        public
    {
        feeHandler = _feeHandler;
    }

    receive() external payable {
        if (isTestingReentrant) {
            feeHandler.claimStakerReward(address(this), 0);
        }
    }

    function setIsTestingReentrancy(bool isTesting) external {
        isTestingReentrant = isTesting;
    }
}