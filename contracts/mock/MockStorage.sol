pragma solidity 0.6.6;

import "../BerryStorage.sol";


contract MockStorage is BerryStorage {
    constructor(
        address _admin,
        IBerryHistory _networkHistory,
        IBerryHistory _feeHandlerHistory,
        IBerryHistory _berryDaoHistory,
        IBerryHistory _matchingEngineHistory
    )
        public
        BerryStorage(
            _admin,
            _networkHistory,
            _feeHandlerHistory,
            _berryDaoHistory,
            _matchingEngineHistory
        )
    {}

    function setReserveId(address reserve, bytes32 reserveId) public {
        reserveAddressToId[reserve] = reserveId;
    }
}