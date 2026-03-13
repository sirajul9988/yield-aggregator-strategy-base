// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

error NotAuthorized();
error StrategyPaused();

/**
 * @title BaseStrategy
 * @dev Abstract contract for building auto-compounding yield strategies.
 */
abstract contract BaseStrategy is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    address public vault;
    address public asset;
    address public rewardToken;

    modifier onlyVault() {
        if (msg.sender != vault) revert NotAuthorized();
        _;
    }

    constructor(address _vault, address _asset, address _rewardToken) Ownable(msg.sender) {
        vault = _vault;
        asset = _asset;
        rewardToken = _rewardToken;
    }

    /**
     * @dev Deploys capital into the underlying protocol.
     */
    function deposit() external virtual onlyVault;

    /**
     * @dev Withdraws a specific amount of assets back to the vault.
     */
    function withdraw(uint256 _amount) external virtual onlyVault;

    /**
     * @dev Claims rewards, swaps to base asset, and reinvests.
     */
    function harvest() external virtual nonReentrant;

    /**
     * @dev Returns total assets managed by this strategy.
     */
    function balanceOfStrategy() public view virtual returns (uint256);

    /**
     * @dev Emergency function to withdraw all assets to the vault.
     */
    function panic() external onlyOwner {
        _withdrawAll();
    }

    function _withdrawAll() internal virtual;
}
