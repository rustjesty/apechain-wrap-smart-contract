// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import { ERC20 } from "@solady/src/tokens/ERC20.sol";
import { FixedPointMathLib } from "@solady/src/utils/FixedPointMathLib.sol";
import { SafeTransferLib } from "@solady/src/utils/SafeTransferLib.sol";

import { ArbInfo } from "./interfaces/ArbInfo.sol";

/// @title Wrapped Native ApeCoin (wnAPE)
/// @author hustleLabs <gm@hustlelabs.xyz>
/// @notice A trustless wrapper contract for native ApeCoin wrapping and unwrapping
/// @dev Implements ERC20 with custom wrapping and unwrapping mechanisms
contract WnAPE is ERC20 {
    using FixedPointMathLib for uint256;
    using SafeTransferLib for address;

    /// @notice Thrown when an invalid amount is provided for wrapping or unwrapping
    error InvalidAmount();

    /// @notice Constructor that configures automatic yield on ApeChain
    constructor() payable {
        // Mint the initial deposit with 1:1 ratio to address(0) to set a non-zero total supply
        _mint(address(0), msg.value);

        // Configure automatic yield on ApeChain
        ArbInfo(address(0x0000000000000000000000000000000000000065)).configureAutomaticYield();
    }

    /// @notice Receive function to allow direct wrapping by sending native tokens
    receive() external payable {
        wrap(msg.value);
    }

    /// @inheritdoc ERC20
    function name() public pure override returns (string memory) {
        return "Wrapped Native ApeCoin";
    }

    /// @inheritdoc ERC20
    function symbol() public pure override returns (string memory) {
        return "wnAPE";
    }

    /// @notice Wraps native APE into wnAPE tokens
    /// @param apeCoinAmount Amount of APE to wrap
    /// @return wnApeCoinAmount Amount of wnAPE tokens minted
    function wrap(uint256 apeCoinAmount) public payable returns (uint256 wnApeCoinAmount) {
        // Validate input amount
        if (apeCoinAmount == 0 || apeCoinAmount != msg.value) revert InvalidAmount();

        // Calculate wnAPE amount based on current pool state
        wnApeCoinAmount = apeCoinAmount.mulDiv(totalSupply(), address(this).balance - apeCoinAmount);

        // Mint wnAPE tokens to sender
        _mint(msg.sender, wnApeCoinAmount);
    }

    /// @notice Unwraps wnAPE tokens back to native APE
    /// @param wnApeCoinAmount Amount of wnAPE tokens to unwrap
    /// @return apeCoinAmount Amount of native APE received
    function unwrap(uint256 wnApeCoinAmount) external returns (uint256 apeCoinAmount) {
        // Validate input amount
        if (wnApeCoinAmount == 0) revert InvalidAmount();

        // Calculate native APE amount to withdraw
        apeCoinAmount = wnApeCoinAmount.mulDiv(address(this).balance, totalSupply());

        // Burn wnAPE tokens
        _burn(msg.sender, wnApeCoinAmount);

        // Transfer native APE
        msg.sender.safeTransferETH(apeCoinAmount);
    }

    /// @notice Calculates wnAPE amount for a given APE amount
    /// @param apeCoinAmount Amount of APE to convert
    /// @return wnApeCoinAmount Equivalent amount of wnAPE tokens
    function getWnApeCoinByApeCoin(uint256 apeCoinAmount) public view returns (uint256 wnApeCoinAmount) {
        wnApeCoinAmount = apeCoinAmount.mulDiv(totalSupply(), address(this).balance);
    }

    /// @notice Calculates APE amount for a given wnAPE amount
    /// @param wnApeCoinAmount Amount of wnAPE tokens to convert
    /// @return apeCoinAmount Equivalent amount of APE
    function getApeCoinByWnApeCoin(uint256 wnApeCoinAmount) public view returns (uint256 apeCoinAmount) {
        apeCoinAmount = wnApeCoinAmount.mulDiv(address(this).balance, totalSupply());
    }

    /// @notice Gets the amount of APE per wnAPE token
    /// @return Amount of APE equivalent to 1 wnAPE
    function apeCoinPerToken() external view returns (uint256) {
        return getApeCoinByWnApeCoin(1 ether);
    }

    /// @notice Gets the amount of wnAPE tokens per APE
    /// @return Amount of wnAPE tokens equivalent to 1 APE
    function tokensPerApeCoin() external view returns (uint256) {
        return getWnApeCoinByApeCoin(1 ether);
    }
}
