// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import { Script, console } from "forge-std/Script.sol";

import { ILayerZeroEndpointV2 } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";

contract SetLibrariesScript is Script {
    function setUp() public { }

    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address _endpoint = vm.envAddress("ENDPOINT");
        address _oapp = vm.envAddress("OAPP");
        uint256 _eid = vm.envUint("EID");
        address _sendLib = vm.envAddress("SEND_LIB");
        address _receiveLib = vm.envAddress("RECEIVE_LIB");

        ILayerZeroEndpointV2 endpoint = ILayerZeroEndpointV2(_endpoint);

        vm.startBroadcast(pk);

        endpoint.setSendLibrary(_oapp, uint32(_eid), _sendLib);
        console.log("Send library set successfully.");

        endpoint.setReceiveLibrary(_oapp, uint32(_eid), _receiveLib, 0);
        console.log("Receive library set successfully.");

        vm.stopBroadcast();
    }
}
