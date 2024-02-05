// SPDX-License-Indentifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import {Script} from "forge-std/Script.sol";

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
        view
        returns (NetworkConfig memory)
    {
        return
            NetworkConfig({
                deployerKey: vm.envUint("DEFAULT_ANVIL_PRIVATE_KEY"),
                deployerAddress: vm.envAddress("DEFAULT_ANVIL_DEPLOYER"),
                airdropNodeRrp: address(0)
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
