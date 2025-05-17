// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import { Script } from "forge-std/Script.sol";

import { ILayerZeroEndpointV2 } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import { SetConfigParam } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";
import { UlnConfig } from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";

/// @title LayerZero Receive Configuration Script
/// @notice Defines and applies ULN (DVN) config for inbound message verification via LayerZero Endpoint V2.
contract SetReceiveConfigScript is Script {
    uint32 constant RECEIVE_CONFIG_TYPE = 2;

    function run() external {
        address endpoint = vm.envAddress("ENDPOINT_ADDRESS");
        address oapp = vm.envAddress("OAPP_ADDRESS");
        uint32 eid = uint32(vm.envUint("REMOTE_EID"));
        address receiveLib = vm.envAddress("RECEIVE_LIB_ADDRESS");
        address lzDVN = vm.envAddress("DVN_ADDRESS");
        uint64 confirmations = uint64(vm.envUint("CONFIRMATIONS"));
        uint256 signer = vm.envUint("PRIVATE_KEY");

        address[] memory requiredDVNsArr = new address[](1);
        requiredDVNsArr[0] = lzDVN;

        /// @notice UlnConfig controls verification threshold for incoming messages
        /// @notice Receive config enforces these settings have been applied to the DVNs and Executor
        /// @dev 0 values will be interpretted as defaults, so to apply NIL settings, use:
        /// @dev uint8 internal constant NIL_DVN_COUNT = type(uint8).max;
        /// @dev uint64 internal constant NIL_CONFIRMATIONS = type(uint64).max;
        UlnConfig memory uln = UlnConfig({
            confirmations: confirmations, // min block confirmations from source
            requiredDVNCount: 1, // required DVNs for message acceptance
            optionalDVNCount: type(uint8).max, // optional DVNs count
            optionalDVNThreshold: 0, // optional DVN threshold
            requiredDVNs: requiredDVNsArr, // sorted required DVNs
            optionalDVNs: new address[](0) // no optional DVNs
         });

        bytes memory encodedUln = abi.encode(uln);

        SetConfigParam[] memory params = new SetConfigParam[](1);
        params[0] = SetConfigParam(eid, RECEIVE_CONFIG_TYPE, encodedUln);

        vm.startBroadcast(signer);
        ILayerZeroEndpointV2(endpoint).setConfig(oapp, receiveLib, params);
        vm.stopBroadcast();
    }
}
