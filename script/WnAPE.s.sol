// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { WnAPE } from "../src/WnAPE.sol";

contract WnAPEScript is Script {
    function setUp() public { }

    function run() public {
        uint256 pk = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(pk);
        new WnAPE();
        vm.stopBroadcast();
    }
}
