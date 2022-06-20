pragma solidity 0.6.6;

import "../EpochUtils.sol";
import "../BerryStaking.sol";


/// @notice Mock Malicious BerryDao tries to re-enter withdraw function in Staking
contract MockMaliciousBerryDaoReentrancy is EpochUtils {
    BerryStaking public staking;
    IERC20 public fib;

    uint256 totalDeposit = 0;

    constructor(
        uint256 _epochPeriod,
        uint256 _startTimestamp,
        BerryStaking _staking,
        IERC20 _fib
    ) public {
        epochPeriodInSeconds = _epochPeriod;
        firstEpochStartTimestamp = _startTimestamp;
        staking = _staking;
        fib = _fib;
        require(_fib.approve(address(_staking), 2**255));
    }

    function deposit(uint256 amount) public {
        staking.deposit(amount);
        totalDeposit += amount;
    }

    function withdraw(uint256 amount) public {
        totalDeposit -= amount;
        staking.withdraw(amount);
    }

    function handleWithdrawal(address, uint256) public {
        if (totalDeposit > 0) {
            // reentrant one
            uint256 amount = totalDeposit;
            totalDeposit = 0;
            staking.withdraw(amount);
        }
    }
}