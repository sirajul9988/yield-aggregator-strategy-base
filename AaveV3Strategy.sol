// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BaseStrategy.sol";

// Minimal interface for Aave V3 Pool
interface IPool {
    function supply(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
    function withdraw(address asset, uint256 amount, address to) external returns (uint256);
}

contract AaveV3Strategy is BaseStrategy {
    using SafeERC20 for IERC20;

    IPool public immutable pool;

    constructor(
        address _vault,
        address _asset,
        address _rewardToken,
        address _pool
    ) BaseStrategy(_vault, _asset, _rewardToken) {
        pool = IPool(_pool);
    }

    function deposit() external override onlyVault {
        uint256 balance = IERC20(asset).balanceOf(address(this));
        if (balance > 0) {
            IERC20(asset).forceApprove(address(pool), balance);
            pool.supply(asset, balance, address(this), 0);
        }
    }

    function withdraw(uint256 _amount) external override onlyVault {
        pool.withdraw(asset, _amount, vault);
    }

    function harvest() external override nonReentrant {
        // 1. Claim Aave Incentives (Implementation varies by chain)
        // 2. Swap RewardToken -> Asset via Uniswap/Sushiswap
        // 3. Redeposit resulting Asset
        
        uint256 amountToReinvest = IERC20(asset).balanceOf(address(this));
        if (amountToReinvest > 0) {
            IERC20(asset).forceApprove(address(pool), amountToReinvest);
            pool.supply(asset, amountToReinvest, address(this), 0);
        }
    }

    function balanceOfStrategy() public view override returns (uint256) {
        // In a real scenario, you would check the balance of aTokens (e.g., aDAI)
        return IERC20(asset).balanceOf(address(this)); 
    }

    function _withdrawAll() internal override {
        uint256 total = balanceOfStrategy();
        if (total > 0) {
            pool.withdraw(asset, total, vault);
        }
    }
}
