# Yield Aggregator Strategy Base

This repository provides a professional-grade boilerplate for building automated yield farming strategies. It follows the "Vault-Strategy" pattern commonly used by protocols like Yearn Finance.

### Architecture
* **Vault:** Handles user deposits, withdrawals, and share accounting (ERC-4626 compliant).
* **Strategy:** Contains the specific logic for where capital is deployed (e.g., supplying DAI to Aave).
* **Auto-Compounding:** Includes a `harvest()` function that claims rewards, swaps them for the underlying asset, and reinvests them.

### Key Logic
1. **Deposit:** User sends assets to the Vault; Vault sends assets to the Strategy.
2. **Harvest:** A keeper calls `harvest()`. The strategy claims governance tokens (e.g., AAVE), swaps them for the base asset on a DEX, and redeposits.
3. **Deleverage:** Emergency functions to pull capital back to the vault in case of market volatility.

### Security
* **Slippage Protection:** Integrated checks for DEX swaps during harvesting.
* **Access Control:** Restricted functions for authorized keepers and governance.
