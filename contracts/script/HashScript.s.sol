
pragma solidity ^0.8.19;

import {Script, console2} from "forge-std/Script.sol";
contract HashScript is Script {
    function run() external {
    }

    function hashCardSecret() public pure returns (bytes32) {
        uint8 card = 2;
        string memory secret = "9c11b2a6876d56";
        bytes32 cardHash = keccak256(
            bytes.concat(bytes1(card), bytes(secret))
        );
        console2.log("card Hash is");
        return cardHash;
    }
}
// card hash for: 2 9c11b2a6876d56 0xbd59f8427d700ccd005d87fd9c83ce7b8171a25a32bfa76a3b1418becc4a265a