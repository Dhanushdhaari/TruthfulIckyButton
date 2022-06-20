pragma solidity 0.6.6;

import "../IBerrySanity.sol";


contract MockSanityRates is IBerrySanity {
    uint256 public sanityRateValue;

    function setSanityRateValue(uint256 _value) external {
        sanityRateValue = _value;
    }

    function getSanityRate(IERC20 src, IERC20 dest) external override view returns (uint256 rate) {
        src;
        dest;
        rate = sanityRateValue;
    }
}