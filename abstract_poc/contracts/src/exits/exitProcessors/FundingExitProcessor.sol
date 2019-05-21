pragma solidity ^0.5.0;
// Should be safe to use. It is marked as experimental as it costs higher gas usage.
// see: https://github.com/ethereum/solidity/issues/5397
pragma experimental ABIEncoderV2;

import "./BaseExitProcessor.sol";
import "../models/FundingExitDataModel.sol";

contract FundingExitProcessor is BaseExitProcessor {
    uint256 constant TX_TYPE = 2;

    constructor(address _framework) BaseExitProcessor(_framework) public {}

    function processExit(uint256 _exitId) external onlyFromFramework {
        bytes memory exitDataInBytes = framework.getBytesStorage(TX_TYPE, bytes32(_exitId));
        FundingExitDataModel.Data memory exitData = abi.decode(exitDataInBytes, (FundingExitDataModel.Data));

        if (exitData.exitable) {
            framework.withdraw(exitData.exitTarget, exitData.amount);
        }
    }

}