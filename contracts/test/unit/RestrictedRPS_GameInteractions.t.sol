
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import {Test, console2} from "forge-std/Test.sol";
import {RestrictedRPSDeploy} from "../../script/RestrictedRPS.s.sol";
import {RestrictedRPSFactory} from "../../src/RestrictedRPSFactory.sol";
import {RestrictedRPSGame} from "../../src/RestrictedRPSGame.sol";
import {TestUtils} from "./Utils.t.sol";

contract RestrictedRPS_GameCreationTest is TestUtils {
    ///////////////////
    // Events
    ///////////////////


    //////////////////
    // Game Playing
    //////////////////
    function test_offeringAMatch() public playersFunded(2) {
        // Create Valid Game
        RestrictedRPSGame game = createGameWithPlayers(2, 1);

        address player1 = PLAYERS[0];

        // offer match
        (uint8 matchId, bytes32 hashedCard) = offerMatch(
            game,
            player1,
            uint8(RestrictedRPSGame.Card.SCISSORS),
            "secret",
            1,
            2
        );
        RestrictedRPSGame.Match memory m = game.getMatches()[matchId];
        RestrictedRPSGame.PlayerState memory playerState = game.getPlayerState(
            0
        );

        assert(m.player1 == 0);
        assert(m.player1Hash == hashedCard);
        assert(m.player1Bet == 1);
        assert(m.player2Bet == 2);
        assert(m.result == RestrictedRPSGame.MatchState.UNDECIDED);
        assert(playerState.nbrStarsLocked == 1);
    }

    function test_cancellingAMatch() public playersFunded(2) {
        // Create Valid Game
        RestrictedRPSGame game = createGameWithPlayers(2, 1);

        address player1 = PLAYERS[0];

        // offer match
        (uint8 matchId, ) = offerMatch(
            game,
            player1,
            uint8(RestrictedRPSGame.Card.SCISSORS),
            "secret",
            1,
            2
        );
        // cancel match
        vm.prank(player1);
        game.cancelMatch(matchId);
        RestrictedRPSGame.Match memory m = game.getMatches()[matchId];
        RestrictedRPSGame.PlayerState memory playerState = game.getPlayerState(
            0
        );

        assert(m.result == RestrictedRPSGame.MatchState.CANCELLED);
        assert(playerState.nbrStarsLocked == 0);
    }

    function test_OfferingTooManyMatches() public playersFunded(2) {
        // Create Valid Game
        RestrictedRPSGame game = createGameWithPlayers(2, 1);

        address player1 = PLAYERS[0];

        // offer match
        for (uint8 i; i < 20; i++) {
            (uint8 matchId, ) = offerMatch(
                game,
                player1,
                uint8(RestrictedRPSGame.Card.SCISSORS),
                "secret",
                1,
                2
            );
            vm.prank(player1);
            game.cancelMatch(matchId);
        }

        vm.expectRevert(
            RestrictedRPSGame
                .RestrictedRPS_PlayerHasOfferedTooManyMatches
                .selector
        );
        offerMatch(game, player1, uint8(RestrictedRPSGame.Card.SCISSORS), "secret", 1, 2);
    }

    function test_answeringAMatch() public playersFunded(2) {
        // Create Valid Game
        RestrictedRPSGame game = createGameWithPlayers(2, 1);

        address player1 = PLAYERS[0];
        address player2 = PLAYERS[1];

        // offer match
        (uint8 matchId, ) = offerMatch(
            game,
            player1,
            uint8(RestrictedRPSGame.Card.SCISSORS),
            "secret",
            1,
            2
        );

        vm.prank(player2);
        game.answerMatch(matchId, RestrictedRPSGame.Card.ROCK);

        RestrictedRPSGame.Match memory m = game.getMatches()[matchId];
        RestrictedRPSGame.PlayerState memory playerState = game.getPlayerState(
            1
        );

        assert(m.player2 == 1);
        assert(m.player2Card == RestrictedRPSGame.Card.ROCK);
        assert(m.result == RestrictedRPSGame.MatchState.ANSWERED);
        assert(playerState.nbrStarsLocked == 2);
    }

    function test_closingAMatchLoss() public playersFunded(2) {
        // Create Valid Game
        RestrictedRPSGame game = createGameWithPlayers(2, 1);

        uint8 p1Bet = 1;
        uint8 p2Bet = 2;
        uint8 matchId = offerAndAnswerAndCloseMatch(game, 0, 1, uint8(RestrictedRPSGame.Card.SCISSORS), uint8(RestrictedRPSGame.Card.ROCK), "secret", p1Bet, p2Bet);
        RestrictedRPSGame.Match memory m = game.getMatches()[matchId];
        RestrictedRPSGame.PlayerState memory p1State = game.getPlayerState(0);
        RestrictedRPSGame.PlayerState memory p2State = game.getPlayerState(1);

        assert(m.player2 == 1);
        assert(m.player1Card == RestrictedRPSGame.Card.SCISSORS);
        assert(m.player2Card == RestrictedRPSGame.Card.ROCK);
        assert(m.result == RestrictedRPSGame.MatchState.WIN2);
        assert(p1State.nbrStarsLocked == 0);
        assert(p2State.nbrStarsLocked == 0);
        assert(p1State.nbrStars == 3 - p1Bet);
        assert(p2State.nbrStars == 3 + p1Bet);
    }

    function test_closingAMatchDraw() public playersFunded(2) {
        // Create Valid Game
        RestrictedRPSGame game = createGameWithPlayers(2, 1);

        uint8 p1Bet = 1;
        uint8 p2Bet = 2;
        uint8 matchId = offerAndAnswerAndCloseMatch(game, 0, 1, uint8(RestrictedRPSGame.Card.SCISSORS), uint8(RestrictedRPSGame.Card.SCISSORS), "secret", p1Bet, p2Bet);
        RestrictedRPSGame.Match memory m = game.getMatches()[matchId];
        RestrictedRPSGame.PlayerState memory p1State = game.getPlayerState(0);
        RestrictedRPSGame.PlayerState memory p2State = game.getPlayerState(1);

        assert(m.player2 == 1);
        assert(m.player1Card == RestrictedRPSGame.Card.SCISSORS);
        assert(m.player2Card == RestrictedRPSGame.Card.SCISSORS);
        assert(m.result == RestrictedRPSGame.MatchState.DRAW);
        assert(p1State.nbrStarsLocked == 0);
        assert(p2State.nbrStarsLocked == 0);
        assert(p1State.nbrStars == 3);
        assert(p2State.nbrStars == 3);
    }
    
    function test_closingAMatchWin() public playersFunded(2) {
        // Create Valid Game
        RestrictedRPSGame game = createGameWithPlayers(2, 1);

        uint8 p1Bet = 1;
        uint8 p2Bet = 2;
        uint8 matchId = offerAndAnswerAndCloseMatch(game, 0, 1, uint8(RestrictedRPSGame.Card.SCISSORS), uint8(RestrictedRPSGame.Card.PAPER), "secret", p1Bet, p2Bet);
        RestrictedRPSGame.Match memory m = game.getMatches()[matchId];
        RestrictedRPSGame.PlayerState memory p1State = game.getPlayerState(0);
        RestrictedRPSGame.PlayerState memory p2State = game.getPlayerState(1);

        assert(m.player2 == 1);
        assert(m.player1Card == RestrictedRPSGame.Card.SCISSORS);
        assert(m.player2Card == RestrictedRPSGame.Card.PAPER);
        assert(m.result == RestrictedRPSGame.MatchState.WIN1);
        assert(p1State.nbrStarsLocked == 0);
        assert(p2State.nbrStarsLocked == 0);
        assert(p1State.nbrStars == 3 + p2Bet);
        assert(p2State.nbrStars == 3 - p2Bet);
    }
}