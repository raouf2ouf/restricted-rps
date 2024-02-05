// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {Config} from "./Config.s.sol";
import {RestrictedRPSFactory} from "../src/RestrictedRPSFactory.sol";
import {RestrictedRPSGame} from "../src/RestrictedRPSGame.sol";

contract RestrictedRPSDeploy is Script {
    function run() external returns (RestrictedRPSFactory) {
        Config config = new Config();

        (uint256 deployerKey, address deployerAddress, address airdropNodeRrp) = config
            .activeNetworkConfig();
        vm.startBroadcast(deployerKey);
        RestrictedRPSFactory restrictedRPSFactory = new RestrictedRPSFactory(deployerAddress, airdropNodeRrp);
        vm.stopBroadcast();
        return restrictedRPSFactory;
    }
}
