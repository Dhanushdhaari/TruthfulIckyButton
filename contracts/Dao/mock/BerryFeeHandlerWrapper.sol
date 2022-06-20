pragma solidity 0.6.6;

import "../../utils/Utils5.sol";
import "../../utils/zeppelin/ReentrancyGuard.sol";
import "../../utils/zeppelin/SafeERC20.sol";
import "../../utils/zeppelin/SafeMath.sol";
import "../../IBerryDao.sol";
import "../../IBerryFeeHandler.sol";
import "../DaoOperator.sol";

interface IFeeHandler is IBerryFeeHandler {
    function feePerPlatformWallet(address) external view returns (uint256);
    function rebatePerWallet(address) external view returns (uint256);
}


contract BerryFeeHandlerWrapper is DaoOperator {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct BerryFeeHandlerData {
        IFeeHandler berryFeeHandler;
        uint256 startEpoch;
    }

    IBerryDao public immutable berryDao;
    IERC20[] internal supportedTokens;
    mapping(IERC20 => BerryFeeHandlerData[]) internal berryFeeHandlersPerToken;
    address public daoSetter;

    event FeeHandlerAdded(IERC20 token, IFeeHandler berryFeeHandler);

    constructor(
        IBerryDao _berryDao,
        address _daoOperator
    ) public DaoOperator(_daoOperator) {
        require(_berryDao != IBerryDao(0), "berryDao 0");
        berryDao = _berryDao;
    }

    function addFeeHandler(IERC20 _token, IFeeHandler _berryFeeHandler) external onlyDaoOperator {
        addTokenToSupportedTokensArray(_token);
        addFeeHandlerToBerryFeeHandlerArray(berryFeeHandlersPerToken[_token], _berryFeeHandler);
        emit FeeHandlerAdded(_token, _berryFeeHandler);
    }

    /// @dev claim from multiple feeHandlers
    /// @param staker staker address
    /// @param epoch epoch for which the staker is claiming the reward
    /// @param startTokenIndex index of supportedTokens to start iterating from (inclusive)
    /// @param endTokenIndex index of supportedTokens to end iterating to (exclusive)
    /// @param startBerryFeeHandlerIndex index of feeHandlerArray to start iterating from (inclusive)
    /// @param endBerryFeeHandlerIndex index of feeHandlerArray to end iterating to (exclusive)
    /// @return amounts staker reward wei / twei amount claimed from each feeHandler
    function claimStakerReward(
        address staker,
        uint256 epoch,
        uint256 startTokenIndex,
        uint256 endTokenIndex,
        uint256 startBerryFeeHandlerIndex,
        uint256 endBerryFeeHandlerIndex
    ) external returns(uint256[] memory amounts) {
        if (
            startTokenIndex > endTokenIndex ||
            startBerryFeeHandlerIndex > endBerryFeeHandlerIndex ||
            supportedTokens.length == 0
        ) {
            // no need to do anything
            return amounts;
        }

        uint256 endTokenId = (endTokenIndex >= supportedTokens.length) ?
            supportedTokens.length : endTokenIndex;

        for (uint256 i = startTokenIndex; i < endTokenId; i++) {
            BerryFeeHandlerData[] memory berryFeeHandlerArray = berryFeeHandlersPerToken[supportedTokens[i]];
            uint256 endBerryFeeHandlerId = (endBerryFeeHandlerIndex >= berryFeeHandlerArray.length) ?
                berryFeeHandlerArray.length - 1: endBerryFeeHandlerIndex - 1;
            require(endBerryFeeHandlerId >= startBerryFeeHandlerIndex, "bad array indices");
            amounts = new uint256[](endBerryFeeHandlerId - startBerryFeeHandlerIndex + 1);

            // iteration starts from endIndex, differs from claiming reserve rebates and platform wallets
            for (uint256 j = endBerryFeeHandlerId; j >= startBerryFeeHandlerIndex; j--) {
                BerryFeeHandlerData memory berryFeeHandlerData = berryFeeHandlerArray[j];
                if (berryFeeHandlerData.startEpoch < epoch) {
                    amounts[j] = berryFeeHandlerData.berryFeeHandler.claimStakerReward(staker, epoch);
                    break;
                } else if (berryFeeHandlerData.startEpoch == epoch) {
                    amounts[j] = berryFeeHandlerData.berryFeeHandler.claimStakerReward(staker, epoch);
                }

                if (j == 0) {
                    break;
                }
            }
        }
    }

    /// @dev claim reabate per reserve wallet. called by any address
    /// @param rebateWallet the wallet to claim rebates for. Total accumulated rebate sent to this wallet
    /// @param startTokenIndex index of supportedTokens to start iterating from (inclusive)
    /// @param endTokenIndex index of supportedTokens to end iterating to (exclusive)
    /// @param startBerryFeeHandlerIndex index of feeHandlerArray to start iterating from (inclusive)
    /// @param endBerryFeeHandlerIndex index of feeHandlerArray to end iterating to (exclusive)
    /// @return amounts reserve rebate wei / twei amount claimed from each feeHandler
    function claimReserveRebate(
        address rebateWallet,
        uint256 startTokenIndex,
        uint256 endTokenIndex,
        uint256 startBerryFeeHandlerIndex,
        uint256 endBerryFeeHandlerIndex
    ) external returns (uint256[] memory amounts) 
    {
        if (
            startTokenIndex > endTokenIndex ||
            startBerryFeeHandlerIndex > endBerryFeeHandlerIndex ||
            supportedTokens.length == 0
        ) {
            // no need to do anything
            return amounts;
        }

        uint256 endTokenId = (endTokenIndex >= supportedTokens.length) ?
            supportedTokens.length : endTokenIndex;

        for (uint256 i = startTokenIndex; i < endTokenId; i++) {
            BerryFeeHandlerData[] memory berryFeeHandlerArray = berryFeeHandlersPerToken[supportedTokens[i]];
            uint256 endBerryFeeHandlerId = (endBerryFeeHandlerIndex >= berryFeeHandlerArray.length) ?
                berryFeeHandlerArray.length : endBerryFeeHandlerIndex;
            require(endBerryFeeHandlerId >= startBerryFeeHandlerIndex, "bad array indices");
            amounts = new uint256[](endBerryFeeHandlerId - startBerryFeeHandlerIndex + 1);
            
            for (uint256 j = startBerryFeeHandlerIndex; j < endBerryFeeHandlerId; j++) {
                IFeeHandler feeHandler = berryFeeHandlerArray[j].berryFeeHandler;
                if (feeHandler.rebatePerWallet(rebateWallet) > 1) {
                    amounts[j] = feeHandler.claimReserveRebate(rebateWallet);
                }
            }
        }
    }

    /// @dev claim accumulated fee per platform wallet. Called by any address
    /// @param platformWallet the wallet to claim fee for. Total accumulated fee sent to this wallet
    /// @param startTokenIndex index of supportedTokens to start iterating from (inclusive)
    /// @param endTokenIndex index of supportedTokens to end iterating to (exclusive)
    /// @param startBerryFeeHandlerIndex index of feeHandlerArray to start iterating from (inclusive)
    /// @param endBerryFeeHandlerIndex index of feeHandlerArray to end iterating to (exclusive)
    /// @return amounts platform fee wei / twei amount claimed from each feeHandler
    function claimPlatformFee(
        address platformWallet,
        uint256 startTokenIndex,
        uint256 endTokenIndex,
        uint256 startBerryFeeHandlerIndex,
        uint256 endBerryFeeHandlerIndex
    ) external returns (uint256[] memory amounts)
    {
        if (
            startTokenIndex > endTokenIndex ||
            startBerryFeeHandlerIndex > endBerryFeeHandlerIndex ||
            supportedTokens.length == 0
        ) {
            // no need to do anything
            return amounts;
        }

        uint256 endTokenId = (endTokenIndex >= supportedTokens.length) ?
            supportedTokens.length : endTokenIndex;

        for (uint256 i = startTokenIndex; i < endTokenId; i++) {
            BerryFeeHandlerData[] memory berryFeeHandlerArray = berryFeeHandlersPerToken[supportedTokens[i]];
            uint256 endBerryFeeHandlerId = (endBerryFeeHandlerIndex >= berryFeeHandlerArray.length) ?
                berryFeeHandlerArray.length : endBerryFeeHandlerIndex;
            require(endBerryFeeHandlerId >= startBerryFeeHandlerIndex, "bad array indices");
            amounts = new uint256[](endBerryFeeHandlerId - startBerryFeeHandlerIndex + 1);

            for (uint256 j = startBerryFeeHandlerIndex; j < endBerryFeeHandlerId; j++) {
                IFeeHandler feeHandler = berryFeeHandlerArray[j].berryFeeHandler;
                if (feeHandler.feePerPlatformWallet(platformWallet) > 1) {
                    amounts[j] = feeHandler.claimPlatformFee(platformWallet);
                }
            }
        }
    }

    function getBerryFeeHandlersPerToken(IERC20 token) external view returns (
        IFeeHandler[] memory berryFeeHandlers,
        uint256[] memory epochs
        )
    {
        BerryFeeHandlerData[] storage berryFeeHandlerData = berryFeeHandlersPerToken[token];
        berryFeeHandlers = new IFeeHandler[](berryFeeHandlerData.length);
        epochs = new uint256[](berryFeeHandlerData.length);
        for (uint i = 0; i < berryFeeHandlerData.length; i++) {
            berryFeeHandlers[i] = berryFeeHandlerData[i].berryFeeHandler;
            epochs[i] = berryFeeHandlerData[i].startEpoch;
        }
    }
    
    function getSupportedTokens() external view returns (IERC20[] memory) {
        return supportedTokens;
    }

    function addTokenToSupportedTokensArray(IERC20 _token) internal {
        uint256 i;
        for (i = 0; i < supportedTokens.length; i++) {
            if (_token == supportedTokens[i]) {
                // already added, return
                return;
            }
        }
        supportedTokens.push(_token);
    }

    function addFeeHandlerToBerryFeeHandlerArray(
        BerryFeeHandlerData[] storage berryFeeHandlerArray,
        IFeeHandler _berryFeeHandler
    ) internal {
        uint256 i;
        for (i = 0; i < berryFeeHandlerArray.length; i++) {
            if (_berryFeeHandler == berryFeeHandlerArray[i].berryFeeHandler) {
                // already added, return
                return;
            }
        }
        berryFeeHandlerArray.push(BerryFeeHandlerData({
            berryFeeHandler: _berryFeeHandler,
            startEpoch: berryDao.getCurrentEpochNumber()
            })
        );
    }
}