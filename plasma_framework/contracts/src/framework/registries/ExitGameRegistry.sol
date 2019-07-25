pragma solidity ^0.5.0;

import "../utils/Operated.sol";
import "../utils/Quarantine.sol";

contract ExitGameRegistry is Operated {
    mapping(uint256 => address) private _exitGames;
    mapping(address => uint256) private _exitGameToTxType;
    using Quarantine for Quarantine.Data;
    Quarantine.Data internal _quarantine;

    event ExitGameRegistered(
        uint256 txType,
        address exitGameAddress
    );

    constructor (uint256 _minExitPeriod, uint256 _initialImmuneExitGames)
        public
    {
        _quarantine.quarantinePeriod = _minExitPeriod;
        _quarantine.immunitiesRemaining = _initialImmuneExitGames;
    }

    modifier onlyFromNonQuarantinedExitGame() {
        require(_exitGameToTxType[msg.sender] != 0, "Not being called by registered exit game contract");
        require(!_quarantine.isQuarantined(msg.sender), "ExitGame is quarantined.");
        _;
    }

    /**
     * @notice Register the exit game to Plasma framework. This can be only called by contract admin.
     * @param _txType tx type that the exit game want to register to.
     * @param _contract Address of the exit game contract.
     */
    function registerExitGame(uint256 _txType, address _contract) public onlyOperator {
        require(_txType != 0, "should not register with tx type 0");
        require(_contract != address(0), "should not register with an empty exit game address");
        require(_exitGames[_txType] == address(0), "The tx type is already registered");
        require(_exitGameToTxType[_contract] == 0, "The exit game contract is already registered");

        _exitGames[_txType] = _contract;
        _exitGameToTxType[_contract] = _txType;
        _quarantine.quarantine(_contract);

        emit ExitGameRegistered(_txType, _contract);
    }

    function exitGames(uint256 _txType) public view returns (address) {
        return _exitGames[_txType];
    }

    function exitGameToTxType(address _exitGame) public view returns (uint256) {
        return _exitGameToTxType[_exitGame];
    }
}
