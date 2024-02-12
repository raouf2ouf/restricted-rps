
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import {Test, console2} from "forge-std/Test.sol";
import {RestrictedRPSDeploy} from "../../script/RestrictedRPS.s.sol";
import {RestrictedRPSFactory} from "../../src/RestrictedRPSFactory.sol";
import {RestrictedRPSGame} from "../../src/RestrictedRPSGame.sol";
import {TestUtils} from "./Utils.t.sol";

contract RestrictedRPS_GameClosingTest is TestUtils {

    function test_GameClosingDealerAFK() public {
        // Create Valid Game
        uint8 duration = 1;
        RestrictedRPSGame game = createGameWithPlayers(6, duration);
        uint256 joiningCost = restrictedRPSFactory.getBasicJoiningCost();
        uint256[] memory balances = new uint256[](6);
        for(uint8 i; i < 6; i++) {
            balances[i] = PLAYERS[i].balance;
            console2.logUint(balances[i]);
        }

        vm.warp(block.timestamp + (duration * 1 days) + 1 days);
        vm.prank(PLAYERS[6]);
        game.closeGameDealerAFK();
       
        for(uint8 i; i < 6; i++) {
            assert((balances[i] + joiningCost) == PLAYERS[i].balance);
        }
    }
}