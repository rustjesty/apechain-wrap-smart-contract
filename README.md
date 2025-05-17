# Wrapped Native ApeCoin (wnAPE) 🦍 🍌

A trustless wrapper contract for native ApeCoin on ApeChain that allows wrapping and unwrapping of native APE tokens.

## Overview

wnAPE (Wrapped Native ApeCoin) is an ERC20-compliant **yield-bearing** token that represents wrapped native APE on ApeChain. Unlike native APE which experiences value changes through ApeChain's automatic yield system, wnAPE functions like a receipt token, representing proportional ownership of the entire APE pool in the contract.

Instead of directly reflecting yield by changing account balances, wnAPE maintains a fixed supply while its redemption value against APE increases over time. This means the same amount of wnAPE tokens will be worth more APE as the pool accumulates yield. When someone exits wnAPE by unwrapping, they receive their principal APE plus any accumulated APE earnings based on their proportional share.

## Features

- **Wrap APE**: Convert native APE to wnAPE tokens
- **Unwrap wnAPE**: Convert wnAPE tokens back to native APE
- **Direct Deposits**: Allows direct wrapping by sending native tokens to the contract
- **Conversion Utilities**: Helper functions to calculate conversion rates between APE and wnAPE

## Usage

### Wrapping APE

```solidity
// Method 1: Using the wrap function
wnAPE.wrap{value: amountToWrap}(amountToWrap);

// Method 2: Simply send APE to the contract
(bool success,) = wnAPE.call{value: amountToWrap}("");
```

### Unwrapping wnAPE

```solidity
// Unwrap wnAPE tokens back to native APE
wnAPE.unwrap(wnApeCoinAmount);
```

### Checking Conversion Rates

```solidity
// Get APE amount for a specific wnAPE amount
uint256 apeAmount = wnAPE.getApeCoinByWnApeCoin(wnApeCoinAmount);

// Get wnAPE amount for a specific APE amount
uint256 wnApeAmount = wnAPE.getWnApeCoinByApeCoin(apeCoinAmount);

// Get APE per 1 wnAPE token
uint256 apePerToken = wnAPE.apeCoinPerToken();

// Get wnAPE tokens per 1 APE
uint256 tokensPerApe = wnAPE.tokensPerApeCoin();
```

## Technical Details

- Solidity version: 0.8.30
- License: MIT
- Dependencies:
  - Solady: ERC20, FixedPointMathLib, SafeTransferLib
  - ArbInfo interface for automatic yield configuration

## License

This project is licensed under the MIT License.
