pragma solidity 0.6.6;

import "../BerryFeeHandler.sol";


contract MaliciousFeeHandler is BerryFeeHandler {
    constructor(
        address daoSetter,
        IBerryProxy _berryNetworkProxy,
        address _berryNetwork,
        IERC20 _fib,
        uint256 _burnBlockInterval,
        address _daoOperator
    )
        public
        BerryFeeHandler(
            daoSetter,
            _berryNetworkProxy,
            _berryNetwork,
            _fib,
            _burnBlockInterval,
            _daoOperator
        )
    {}

    function setTotalPayoutBalance(uint256 _amount) external {
        totalPayoutBalance = _amount;
    }

    function withdrawEther(uint256 amount, address payable sendTo) external {
        sendTo.transfer(amount);
    }
}