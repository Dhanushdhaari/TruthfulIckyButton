pragma solidity 0.6.6;

import "../BerryDao.sol";


contract MockMaliciousBerryDao is BerryDao {
    constructor(
        uint256 _epochPeriod,
        uint256 _startTimestamp,
        IERC20 _fib,
        uint256 _minCampDuration,
        uint256 _defaultNetworkFeeBps,
        uint256 _defaultRewardBps,
        uint256 _defaultRebateBps,
        address _admin
    )
        public
        BerryDao(
            _epochPeriod,
            _startTimestamp,
            _fib,
            _defaultNetworkFeeBps,
            _defaultRewardBps,
            _defaultRebateBps,
            _admin
        )
    {
        minCampaignDurationInSeconds = _minCampDuration;
    }

    function setTotalEpochPoints(uint256 epoch, uint256 pts) public {
        totalEpochPoints[epoch] = pts;
    }
}