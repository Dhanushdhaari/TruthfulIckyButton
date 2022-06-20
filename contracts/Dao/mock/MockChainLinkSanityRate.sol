pragma solidity 0.6.6;

import "../ISanityRate.sol";


contract MockChainLinkSanityRate is ISanityRate {
    uint256 latestAnswerValue;

    function setLatestFibToEthRate(uint256 _fibEthRate) external {
        latestAnswerValue = _fibEthRate;
    }

    function latestAnswer() external view override returns (uint256) {
        return latestAnswerValue;
    }
}