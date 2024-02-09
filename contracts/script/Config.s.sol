// SPDX-License-Indentifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import {Script} from "forge-std/Script.sol";
import {AirnodeRrpV0Mock} from "../test/mock/AirnodeRrpV0Mock.sol";

contract Config is Script {
    struct NetworkConfig {
        uint256 deployerKey;
        address deployerAddress;
        address airdropNodeRrp;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if(block.chainid == 1891) {
            activeNetworkConfig = getLightLinkTestConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getOrCreateAnvilEthConfig()
        public
        returns (NetworkConfig memory)
    {
        AirnodeRrpV0Mock airnodeMock = new AirnodeRrpV0Mock();
        return
            NetworkConfig({
                deployerKey: vm.envUint("DEFAULT_ANVIL_PRIVATE_KEY"),
                deployerAddress: vm.envAddress("DEFAULT_ANVIL_DEPLOYER"),
                airdropNodeRrp: address(airnodeMock)
            });
    }

    function getLightLinkTestConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            deployerKey: vm.envUint("PRIVATE_KEY"),
            deployerAddress: vm.envAddress("OWNER_ADDRESS"),
            airdropNodeRrp: vm.envAddress("AIRDROP_NODE_RRP")
        });
    }
}
