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
    event GameCreated(uint256 indexed gameId, address indexed gameAddress);

    event GameJoined(address indexed player);
    event GameStarted();
    event GamePlayerWasGivenHand(uint8 indexed playerId, bytes32 encryptedHand);


    //////////////////
    // Game Create
    //////////////////
    function test_GameCreation() public {
        bytes9 deck = generateDeck();
        bytes32 initialHash = hashDeck(deck, "secret");
        uint8 duration = 1;
        (uint8 gameId, ) = createGame(initialHash, duration, GAME_CREATION_FEE);

        RestrictedRPSGame game = RestrictedRPSGame(
            restrictedRPSFactory.getGame(gameId)
        );

        assert(game.getState() == RestrictedRPSGame.GameState.WAITING_FOR_SEED);
        assert(game.getDealer() == DEALER);
        assert(game.getInitialHash() == initialHash);
        assert(game.getDuration() == duration);
        assert(game.getEnd() > block.timestamp && game.getEnd() <= (block.timestamp + (duration * 1 days)));
    }

    function test_GameCreationWithInsufficiantFunds() public {
        bytes9 deck = generateDeck();
        bytes32 initialHash = hashDeck(deck, "secret");
        uint8 duration = 1;
        (uint8 gameId, ) = createGame(initialHash, duration, GAME_CREATION_FEE);
        vm.expectRevert(
            RestrictedRPSFactory.RestrictedRPSFactory_SendMore.selector
        );
        createGame(initialHash, duration, 0);
    }

    function test_GameCreationWithTooManyOpenGames() public {
        bytes9 deck = generateDeck();
        bytes32 initialHash = hashDeck(deck, "secret");
        uint8 duration = 1;

        for (uint8 i; i < NBR_GAMES; i++) {
            createGame(initialHash, duration, GAME_CREATION_FEE);
        }
        vm.expectRevert(
            RestrictedRPSFactory.RestrictedRPSFactory_TooManyOpenGames.selector
        );
        createGame(initialHash, duration, GAME_CREATION_FEE);
    }

    function test_SeedOpenGame() public {
        bytes9 deck = generateDeck();
        bytes32 initialHash = hashDeck(deck, "secret");
        uint8 duration = 1;
        (uint8 gameId, ) = createGame(initialHash, duration, GAME_CREATION_FEE);

        RestrictedRPSGame game = RestrictedRPSGame(
            restrictedRPSFactory.getGame(gameId)
        );
        assert(game.getState() == RestrictedRPSGame.GameState.WAITING_FOR_SEED);

        vm.prank(DEALER);
        uint256 seed = 12345678910;
        seedWithRNG(seed);

        assert(game.getState() == RestrictedRPSGame.GameState.OPEN);
        assert(game.getSeed() == seed);
    }

    function test_GameCreationWithReset() public {
        // bytes32 initialHash = 0x0;
        // uint8 duration = 1;

        // for (uint8 i; i < MAX_GAMES; i++) {
        //     createGame(initialHash, duration, GAME_CREATION_FEE);
        // }

        // // TODO close last game

        // uint8 gameId = createGame(initialHash, duration, GAME_CREATION_FEE);
        // assert(gameId == 0);
    }

    //////////////////
    // Game Joining
    //////////////////
    function test_JoiningGame() public playersFunded(1) {
        bytes9 deck = generateDeck();
        bytes32 initialHash = hashDeck(deck, "secret");
        uint8 duration = 1;
        (uint8 gameId, ) = createGame(initialHash, duration, GAME_CREATION_FEE);

        RestrictedRPSGame game = RestrictedRPSGame(
            restrictedRPSFactory.getGame(gameId)
        );
        uint256 seed = 12345678910;
        seedWithRNG(seed);

        address player = PLAYERS[0];
        uint256 amount = restrictedRPSFactory.getBasicJoiningCost();
        vm.startPrank(player);
        uint8 playerId = game.joinGame{
            value: amount
        }("");
        vm.stopPrank();

        RestrictedRPSGame.PlayerState memory playerState = game.getPlayerState(
            playerId
        );

        assert(playerState.player == player);
        assert(playerState.encryptedHand == 0x0);
        assert(playerState.nbrStars == NBR_STARS);
        assert(playerState.nbrStarsLocked == 0);
        assert(playerState.nbrRockUsed == 0);
        assert(playerState.nbrPaperUsed == 0);
        assert(playerState.nbrScissorsUsed == 0);
        assert(playerState.paidAmount == amount);
    }

    function test_JoiningGameWithInsufficiantFunds() public playersFunded(1) {
        bytes9 deck = generateDeck();
        bytes32 initialHash = hashDeck(deck, "secret");
        uint8 duration = 1;
        (uint8 gameId, ) = createGame(initialHash, duration, GAME_CREATION_FEE);

        RestrictedRPSGame game = RestrictedRPSGame(
            restrictedRPSFactory.getGame(gameId)
        );
        uint256 seed = 12345678910;
        seedWithRNG(seed);

        address player = PLAYERS[0];
        vm.expectRevert(RestrictedRPSGame.RestrictedRPS_SendMore.selector);
        vm.prank(player);
        game.joinGame{value: 1}("");
    }

    function test_JoiningAFullGame() public playersFunded(7) {
        bytes9 deck = generateDeck();
        bytes32 initialHash = hashDeck(deck, "secret");
        uint8 duration = 1;
        (uint8 gameId, ) = createGame(initialHash, duration, GAME_CREATION_FEE);

        RestrictedRPSGame game = RestrictedRPSGame(
            restrictedRPSFactory.getGame(gameId)
        );
        uint256 seed = 12345678910;
        seedWithRNG(seed);

        uint256 joiningCost = restrictedRPSFactory.getBasicJoiningCost();

        for (uint8 i; i < 6; i++) {
            vm.prank(PLAYERS[i]);
            game.joinGame{value: joiningCost}("");
        }

        vm.expectRevert(RestrictedRPSGame.RestrictedRPS_GameFull.selector);
        vm.prank(PLAYERS[6]);
        game.joinGame{value: joiningCost}("");
    }

    function test_JoiningANonOpenGame() public playersFunded(1) {
        bytes9 deck = generateDeck();
        bytes32 initialHash = hashDeck(deck, "secret");
        uint8 duration = 1;
        (uint8 gameId, ) = createGame(initialHash, duration, GAME_CREATION_FEE);

        RestrictedRPSGame game = RestrictedRPSGame(
            restrictedRPSFactory.getGame(gameId)
        );
        address player = PLAYERS[0];
        uint256 joiningCost = restrictedRPSFactory.getBasicJoiningCost();
        vm.expectRevert(RestrictedRPSGame.RestrictedRPS_GameNotOpen.selector);
        vm.startPrank(player);
        uint8 playerId = game.joinGame{
            value: joiningCost
        }("");
        vm.stopPrank();
    }

    function test_DealerJoining() public playersFunded(1) {
        bytes9 deck = generateDeck();
        bytes32 initialHash = hashDeck(deck, "secret");
        uint8 duration = 1;
        (uint8 gameId, ) = createGame(initialHash, duration, GAME_CREATION_FEE);

        RestrictedRPSGame game = RestrictedRPSGame(
            restrictedRPSFactory.getGame(gameId)
        );
        uint256 seed = 12345678910;
        seedWithRNG(seed);
        uint256 joiningCost = restrictedRPSFactory.getBasicJoiningCost();

        vm.expectRevert(
            RestrictedRPSGame.RestrictedRPS_DealerCannotJoin.selector
        );
        vm.prank(DEALER);
        game.joinGame{value: joiningCost}("");
    }

    function test_JoiningTwiceSameGame() public playersFunded(7) {
        RestrictedRPSGame game = createGameWithPlayers(4, 1);
        uint256 joiningCost = restrictedRPSFactory.getBasicJoiningCost();

        vm.expectRevert(
            RestrictedRPSGame.RestrictedRPS_PlayerAlreadyJoined.selector
        );
        vm.prank(PLAYERS[2]);
        game.joinGame{value: joiningCost}("");
    }

}
