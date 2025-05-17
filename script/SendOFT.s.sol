// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import { Script, console } from "forge-std/Script.sol";

import { IOAppCore } from "@layerzerolabs/oapp-evm/contracts/oapp/interfaces/IOAppCore.sol";
import { SendParam, OFTReceipt } from "@layerzerolabs/oft-evm/contracts/interfaces/IOFT.sol";
import { OptionsBuilder } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";
import { MessagingFee } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { WnAPEOFTAdapter } from "../src/lz/WnAPEOFTAdapter.sol";

contract SendOFTScript is Script {
    using OptionsBuilder for bytes;

    /**
     * @dev Converts an address to bytes32.
     * @param _addr The address to convert.
     * @return The bytes32 representation of the address.
     */
    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }

    function run() public {
        // Fetching environment variables
        address tokenAddress = vm.envAddress("TOKEN_ADDRESS");
        address oftAddress = vm.envAddress("OFT_ADDRESS");
        address toAddress = vm.envAddress("TO_ADDRESS");
        uint256 _tokensToSend = vm.envUint("TOKENS_TO_SEND");

        // Fetch the private key from environment variable
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting with the private key
        vm.startBroadcast(privateKey);

        IERC20(tokenAddress).approve(oftAddress, _tokensToSend);

        WnAPEOFTAdapter sourceOFT = WnAPEOFTAdapter(oftAddress);

        bytes memory _extraOptions = OptionsBuilder.newOptions().addExecutorLzReceiveOption(65_000, 0);
        SendParam memory sendParam = SendParam(
            30_101, // You can also make this dynamic if needed
            addressToBytes32(toAddress),
            _tokensToSend,
            (_tokensToSend * 9) / 10,
            _extraOptions,
            "",
            ""
        );

        MessagingFee memory fee = sourceOFT.quoteSend(sendParam, false);

        console.log("Fee amount: ", fee.nativeFee);

        sourceOFT.send{ value: fee.nativeFee }(sendParam, fee, msg.sender);

        // Stop broadcasting
        vm.stopBroadcast();
    }
}
