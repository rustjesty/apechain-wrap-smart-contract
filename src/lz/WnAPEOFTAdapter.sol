// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import { OFTAdapter } from "@layerzerolabs/oft-evm/contracts/OFTAdapter.sol";
import { Ownable } from "openzeppelin-contracts/contracts/access/Ownable.sol";

/// @title OFTAdapter Contract for Wrapped Native ApeCoin (wnAPE)
/// @author hustleLabs <gm@hustlelabs.xyz>
/// @notice OFTAdapter uses a deployed ERC-20 token and safeERC20 to interact with the OFTCore contract
/// @dev OFTAdapter is a contract that adapts an ERC-20 token to the OFT functionality
contract WnAPEOFTAdapter is OFTAdapter {
    constructor(
        address _token,
        address _lzEndpoint,
        address _delegate
    )
        OFTAdapter(_token, _lzEndpoint, _delegate)
        Ownable(_delegate)
    { }
}
