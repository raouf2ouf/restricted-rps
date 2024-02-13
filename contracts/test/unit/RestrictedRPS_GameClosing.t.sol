
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
        }

        vm.warp(block.timestamp + (duration * 1 days) + 1 days);
        vm.prank(PLAYERS[6]);
        game.closeGame();
        game.payPlayers();
       
        for(uint8 i; i < 6; i++) {
            assert((balances[i] + joiningCost) == PLAYERS[i].balance);
        }
    }

    function test_GameClosingHalfFinishedGameDealerAFK() public {
        // Create Valid Game
        uint8 duration = 1;
        RestrictedRPSGame game = createGameWithPlayers(6, duration);
        uint256 joiningCost = restrictedRPSFactory.getBasicJoiningCost();

        offerAndAnswerAndCloseMatch(game, 0, 1, uint8(RestrictedRPSGame.Card.ROCK), uint8(RestrictedRPSGame.Card.SCISSORS), "secret", 1, 1);
        offerAndAnswerAndCloseMatch(game, 2, 3, uint8(RestrictedRPSGame.Card.ROCK), uint8(RestrictedRPSGame.Card.ROCK), "secret", 1, 1);
        offerAndAnswerAndCloseMatch(game, 4, 5, uint8(RestrictedRPSGame.Card.ROCK), uint8(RestrictedRPSGame.Card.ROCK), "secret", 1, 1);

        uint256[] memory balances = new uint256[](6);
        for(uint8 i; i < 6; i++) {
            balances[i] = PLAYERS[i].balance;
        }

        vm.warp(block.timestamp + (duration * 1 days) + 1 days);
        vm.prank(PLAYERS[6]);
        game.closeGame();
        game.payPlayers();
       
        for(uint8 i; i < 6; i++) {
            assert((balances[i] + joiningCost) == PLAYERS[i].balance);
        }
    }

    function test_GameClosingWithoutVerficiation() public {
        // Create Valid Game
        uint8 duration = 1;
        RestrictedRPSGame game = createGameWithPlayers(2, duration);
        uint256 joiningCost = restrictedRPSFactory.getBasicJoiningCost();

        offerAndAnswerAndCloseMatch(game, 0, 1, uint8(RestrictedRPSGame.Card.ROCK), uint8(RestrictedRPSGame.Card.SCISSORS), "secret", 1, 1);
        offerAndAnswerAndCloseMatch(game, 0, 1, uint8(RestrictedRPSGame.Card.ROCK), uint8(RestrictedRPSGame.Card.ROCK), "secret", 1, 1);
        offerAndAnswerAndCloseMatch(game, 0, 1, uint8(RestrictedRPSGame.Card.ROCK), uint8(RestrictedRPSGame.Card.ROCK), "secret", 1, 1);
        offerAndAnswerAndCloseMatch(game, 0, 1, uint8(RestrictedRPSGame.Card.ROCK), uint8(RestrictedRPSGame.Card.ROCK), "secret", 1, 1);
        offerAndAnswerAndCloseMatch(game, 0, 1, uint8(RestrictedRPSGame.Card.ROCK), uint8(RestrictedRPSGame.Card.ROCK), "secret", 1, 1);
        offerAndAnswerAndCloseMatch(game, 0, 1, uint8(RestrictedRPSGame.Card.ROCK), uint8(RestrictedRPSGame.Card.ROCK), "secret", 1, 1);

        uint256 player1Balance = PLAYERS[0].balance;
        uint256 player2Balance = PLAYERS[0].balance;

        vm.expectRevert(
            RestrictedRPSGame.RestrictedRPS_GameNotClosable.selector
        );
        game.closeGame();
    }

    function test_GameClosingFullGameAfterVerification() public {
        // Create Valid Game
        bytes9 initialDeck = generateDeck();
        uint8 duration = 1;
        RestrictedRPSGame game = createGameWithPlayers(2, duration);
        uint256 joiningCost = restrictedRPSFactory.getBasicJoiningCost();

        // player 1 has 3 rocks and 3 scissors, player 2 has 2 rocks, 1 paper, and 3 scissors;

        offerAndAnswerAndCloseMatch(game, 0, 1, uint8(RestrictedRPSGame.Card.ROCK), uint8(RestrictedRPSGame.Card.SCISSORS), "secret", 1, 1);
        offerAndAnswerAndCloseMatch(game, 0, 1, uint8(RestrictedRPSGame.Card.ROCK), uint8(RestrictedRPSGame.Card.ROCK), "secret", 1, 1);
        offerAndAnswerAndCloseMatch(game, 0, 1, uint8(RestrictedRPSGame.Card.ROCK), uint8(RestrictedRPSGame.Card.ROCK), "secret", 1, 1);
        offerAndAnswerAndCloseMatch(game, 0, 1, uint8(RestrictedRPSGame.Card.SCISSORS), uint8(RestrictedRPSGame.Card.PAPER), "secret", 1, 1);
        offerAndAnswerAndCloseMatch(game, 0, 1, uint8(RestrictedRPSGame.Card.SCISSORS), uint8(RestrictedRPSGame.Card.SCISSORS), "secret", 1, 1);
        offerAndAnswerAndCloseMatch(game, 0, 1, uint8(RestrictedRPSGame.Card.SCISSORS), uint8(RestrictedRPSGame.Card.SCISSORS), "secret", 1, 1);

        uint256 player1Balance = PLAYERS[0].balance;
        uint256 player2Balance = PLAYERS[1].balance;

        vm.prank(DEALER);
        game.verifyDealerHonesty(initialDeck, "secret");

        game.computeRewards();

        game.closeGame();
        game.payPlayers();

        uint256 p1W = 5 * game.getStarCost();
        p1W = (p1W * (1000 - 1)) / 1000;

        uint256 p2W = 1 * game.getStarCost();
        p2W = (p2W * (1000 - 1)) / 1000;
        assert((player1Balance + p1W) == PLAYERS[0].balance);
        assert((player2Balance + p2W) == PLAYERS[1].balance);
    }

    function test_GameClosingAfterPlayerCheated() public {
        // Create Valid Game
        bytes9 initialDeck = generateDeck();
        uint8 duration = 1;
        RestrictedRPSGame game = createGameWithPlayers(2, duration);
        uint256 joiningCost = restrictedRPSFactory.getBasicJoiningCost();

        // player 1 has 3 rocks and 3 scissors, player 2 has 2 rocks, 1 paper, and 3 scissors;

        offerAndAnswerAndCloseMatch(game, 0, 1, uint8(RestrictedRPSGame.Card.ROCK), uint8(RestrictedRPSGame.Card.SCISSORS), "secret", 1, 1);
        offerAndAnswerAndCloseMatch(game, 0, 1, uint8(RestrictedRPSGame.Card.ROCK), uint8(RestrictedRPSGame.Card.ROCK), "secret", 1, 1);
        offerAndAnswerAndCloseMatch(game, 0, 1, uint8(RestrictedRPSGame.Card.ROCK), uint8(RestrictedRPSGame.Card.ROCK), "secret", 1, 1);
        offerAndAnswerAndCloseMatch(game, 0, 1, uint8(RestrictedRPSGame.Card.PAPER), uint8(RestrictedRPSGame.Card.PAPER), "secret", 1, 1);
        offerAndAnswerAndCloseMatch(game, 0, 1, uint8(RestrictedRPSGame.Card.SCISSORS), uint8(RestrictedRPSGame.Card.SCISSORS), "secret", 1, 1);
        offerAndAnswerAndCloseMatch(game, 0, 1, uint8(RestrictedRPSGame.Card.SCISSORS), uint8(RestrictedRPSGame.Card.SCISSORS), "secret", 1, 1);

        uint256 player1Balance = PLAYERS[0].balance;
        uint256 player2Balance = PLAYERS[1].balance;

        vm.prank(DEALER);
        game.verifyDealerHonesty(initialDeck, "secret");

        game.computeRewards();

        game.closeGame();
        game.payPlayers();

        assert((player1Balance) == PLAYERS[0].balance); // player 1 cheated
        assert((player2Balance + joiningCost) == PLAYERS[1].balance);
    }

    function test_GameClosingAfterDealerCheated() public {
        // Create Valid Game
        bytes9 initialDeck = generateDeck();
        initialDeck = restrictedRPSFactory.setCard(initialDeck, 0, 1); // replace a rock with paper;
        uint8 duration = 1;
        RestrictedRPSGame game = createGameWithPlayersGivenInitialDeck(initialDeck, 2, duration);
        uint256 joiningCost = restrictedRPSFactory.getBasicJoiningCost();

        // player 1 has 3 rocks and 3 scissors, player 2 has 2 rocks, 1 paper, and 3 scissors;

        offerAndAnswerAndCloseMatch(game, 0, 1, uint8(RestrictedRPSGame.Card.ROCK), uint8(RestrictedRPSGame.Card.SCISSORS), "secret", 1, 1);
        offerAndAnswerAndCloseMatch(game, 0, 1, uint8(RestrictedRPSGame.Card.ROCK), uint8(RestrictedRPSGame.Card.ROCK), "secret", 1, 1);
        offerAndAnswerAndCloseMatch(game, 0, 1, uint8(RestrictedRPSGame.Card.ROCK), uint8(RestrictedRPSGame.Card.ROCK), "secret", 1, 1);
        offerAndAnswerAndCloseMatch(game, 0, 1, uint8(RestrictedRPSGame.Card.SCISSORS), uint8(RestrictedRPSGame.Card.PAPER), "secret", 1, 1);
        offerAndAnswerAndCloseMatch(game, 0, 1, uint8(RestrictedRPSGame.Card.SCISSORS), uint8(RestrictedRPSGame.Card.SCISSORS), "secret", 1, 1);
        offerAndAnswerAndCloseMatch(game, 0, 1, uint8(RestrictedRPSGame.Card.SCISSORS), uint8(RestrictedRPSGame.Card.SCISSORS), "secret", 1, 1);

        uint256 player1Balance = PLAYERS[0].balance;
        uint256 player2Balance = PLAYERS[1].balance;

        vm.prank(DEALER);
        game.verifyDealerHonesty(initialDeck, "secret");

        game.closeGame();
        game.payPlayers();

        assert((player1Balance + joiningCost) == PLAYERS[0].balance);
        assert((player2Balance + joiningCost) == PLAYERS[1].balance);
    }
}