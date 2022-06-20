pragma solidity 0.6.6;

import "../emergency/EmergencyFeeHandler.sol";

contract MockEmergencyFeeHandler is EmergencyBerryFeeHandler {
    constructor(
        address admin,
        address _berryNetwork,
        uint256 _rewardBps,
        uint256 _rebateBps,
        uint256 _burnBps
    ) public EmergencyBerryFeeHandler(admin, _berryNetwork, _rewardBps, _rebateBps, _burnBps) {}

    function calculateAndRecordFeeData(
        address,
        uint256,
        address[] calldata,
        uint256[] calldata,
        uint256
    ) external override {
        revert();
    }
}