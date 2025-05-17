// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import { OFT } from "@layerzerolabs/oft-evm/contracts/OFT.sol";
import { Ownable } from "openzeppelin-contracts/contracts/access/Ownable.sol";

/// @title Wrapped Native ApeCoin (wnAPE) OFT
/// @author hustleLabs <gm@hustlelabs.xyz>
/// @notice wnAPE OFT implementation for cross-chain transfers
/// @dev OFT is an ERC-20 token that extends the functionality of the OFTCore contract
contract WnAPEOFT is OFT {
    constructor(
        address _lzEndpoint,
        address _owner
    )
        OFT("Wrapped Native ApeCoin", "wnAPE", _lzEndpoint, _owner)
        Ownable(_owner)
    { }
}
