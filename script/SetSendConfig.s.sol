// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import { Script } from "forge-std/Script.sol";

import { ILayerZeroEndpointV2 } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import { SetConfigParam } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";
import { UlnConfig } from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";
import { ExecutorConfig } from "@layerzerolabs/lz-evm-messagelib-v2/contracts/SendLibBase.sol";

/// @title LayerZero Send Configuration Script
/// @notice Defines and applies ULN (DVN) + Executor configs for cross‑chain messaging via LayerZero Endpoint V2.
contract SetSendConfigScript is Script {
    uint32 constant EXECUTOR_CONFIG_TYPE = 1;
    uint32 constant ULN_CONFIG_TYPE = 2;

    /// @notice Broadcasts transactions to set both Send ULN and Executor configurations
    function run() external {
        address endpoint = vm.envAddress("SOURCE_ENDPOINT_ADDRESS");
        address oapp = vm.envAddress("SENDER_OAPP_ADDRESS");
        uint32 eid = uint32(vm.envUint("REMOTE_EID"));
        address sendLib = vm.envAddress("SEND_LIB_ADDRESS");
        address lzDVN = vm.envAddress("DVN_ADDRESS");
        address executor = vm.envAddress("EXECUTOR_ADDRESS");
        uint64 confirmations = uint64(vm.envUint("CONFIRMATIONS"));
        uint256 signer = vm.envUint("PRIVATE_KEY");

        address[] memory requiredDVNsArr = new address[](1);
        requiredDVNsArr[0] = lzDVN;

        /// @notice ULNConfig defines security parameters (DVNs + confirmation threshold)
        /// @notice Send config requests these settings to be applied to the DVNs and Executor
        /// @dev 0 values will be interpretted as defaults, so to apply NIL settings, use:
        /// @dev uint8 internal constant NIL_DVN_COUNT = type(uint8).max;
        /// @dev uint64 internal constant NIL_CONFIRMATIONS = type(uint64).max;
        UlnConfig memory uln = UlnConfig({
            confirmations: confirmations, // minimum block confirmations required
            requiredDVNCount: 1, // number of DVNs required
            optionalDVNCount: type(uint8).max, // optional DVNs count, uint8
            optionalDVNThreshold: 0, // optional DVN threshold
            requiredDVNs: requiredDVNsArr, // sorted list of required DVN addresses
            optionalDVNs: new address[](0) // sorted list of optional DVNs
         });

        /// @notice ExecutorConfig sets message size limit + fee‑paying executor
        ExecutorConfig memory exec = ExecutorConfig({
            maxMessageSize: 10_000, // max bytes per cross-chain message
            executor: executor // address that pays destination execution fees
         });

        bytes memory encodedUln = abi.encode(uln);
        bytes memory encodedExec = abi.encode(exec);

        SetConfigParam[] memory params = new SetConfigParam[](2);
        params[0] = SetConfigParam(eid, EXECUTOR_CONFIG_TYPE, encodedExec);
        params[1] = SetConfigParam(eid, ULN_CONFIG_TYPE, encodedUln);

        vm.startBroadcast(signer);
        ILayerZeroEndpointV2(endpoint).setConfig(oapp, sendLib, params);
        vm.stopBroadcast();
    }
}
