// SPDX-License-Identifier: MIT
// pragma solidity >=0.8.19 <0.9.0;

// import {Test, console2} from "forge-std/Test.sol";
// import {RestrictedRPSDeploy} from "../../script/RestrictedRPS.s.sol";
// import {RestrictedRPSFactory} from "../../src/RestrictedRPSFactory.sol";
// import {RestrictedRPSGame} from "../../src/RestrictedRPSGame.sol";

// contract RestrictedRPSTest is Test {
//     ///////////////////
//     // Events
//     ///////////////////
//     event GameCreated(uint256 indexed gameId, address indexed gameAddress);

//     event GameJoined(address indexed player);
//     event GameStarted();
//     event GamePlayerWasGivenHand(uint8 indexed playerId, bytes32 encryptedHand);

//     RestrictedRPSFactory public restrictedRPSFactory;

//     uint256 public constant STARTING_USER_BALANCE = 10 ether;
//     uint256 public constant GAME_CREATION_FEE = 1;
//     uint8 public constant MAX_GAMES = 100;
//     uint8 public constant NBR_STARS = 3;

//     address public DEALER = makeAddr("dealer");
//     address[] public PLAYERS = [
//         makeAddr("player1"),
//         makeAddr("player2"),
//         makeAddr("player3"),
//         makeAddr("player4"),
//         makeAddr("player5"),
//         makeAddr("player6"),
//         makeAddr("player7")
//     ];

//     function setUp() public {
//         RestrictedRPSDeploy restrictedRPSScript = new RestrictedRPSDeploy();
//         restrictedRPSFactory = restrictedRPSScript.run();
//     }

//     modifier dealerFunded() {
//         vm.deal(DEALER, STARTING_USER_BALANCE);
//         _;
//     }

//     modifier playersFunded(uint8 nbrPlayers) {
//         for (uint8 i; i < nbrPlayers; i++) {
//             vm.deal(PLAYERS[i], STARTING_USER_BALANCE);
//         }
//         _;
//     }

//     function createGame(
//         bytes32 _initialHash,
//         uint8 _duration,
//         uint256 fee
//     ) public dealerFunded returns (uint8 gameId, address gameAddress) {
//         vm.prank(DEALER);
//         (gameId, gameAddress) = restrictedRPSFactory.createGame{value: fee}(
//                 _initialHash,
//                 _duration
//             );
//     }

//     function generateDeck() public pure returns (bytes9) {
//         bytes9 deck;
//         for (uint8 i; i < 36; i++) {
//             uint8 card = uint8(i % 3);
//             uint8 shiftAmount = uint8((i % 4) * 2);
//             deck |= bytes9(uint72(card)) << shiftAmount;
//         }
//         return deck;
//     }

//     function createValidGame(
//         uint8 _nbrPlayers,
//         uint8 _duration
//     ) public playersFunded(_nbrPlayers) returns (RestrictedRPSGame game) {
//         bytes9 deck = generateDeck();
//         bytes32 initialHash = keccak256(bytes.concat(deck, bytes("secret")));
//         (uint8 gameId, ) = createGame(initialHash, _duration, GAME_CREATION_FEE);
//         uint256 joiningCost = restrictedRPSFactory.getBasicJoiningCost();

//         game = RestrictedRPSGame(restrictedRPSFactory.getGame(gameId));

//         for (uint8 i; i < _nbrPlayers; i++) {
//             vm.prank(PLAYERS[i]);
//             game.joinGame{value: joiningCost}("");
//         }
//     }

//     function offerMatch(
//         RestrictedRPSGame game,
//         address player,
//         uint8 card,
//         uint8 player1Bet,
//         uint8 player2Bet
//     ) public returns (uint8 matchId, bytes32 hashedCard) {
//         // offer a match
//         hashedCard = keccak256(bytes.concat(bytes1(card), bytes("secret1")));
//         vm.prank(player);
//         matchId = game.offerMatch(hashedCard, player1Bet, player2Bet);
//     }

//     //////////////////
//     // Game Create
//     //////////////////
//     function test_GameCreation() public {
//         bytes32 initialHash = 0x0;
//         uint8 duration = 1;

//         (uint8 gameId,) = createGame(initialHash, duration, GAME_CREATION_FEE);

//         RestrictedRPSGame game = RestrictedRPSGame(
//             restrictedRPSFactory.getGame(gameId)
//         );

//         assert(game.getState() == RestrictedRPSGame.GameState.OPEN);
//         assert(game.getDealer() == DEALER);
//         assert(game.getInitialHash() == initialHash);
//         assert(game.getDuration() == duration);
//     }

//     function test_GameCreationWithInsufficiantFunds() public {
//         bytes32 initialHash = 0x0;
//         uint8 duration = 1;
//         vm.expectRevert(
//             RestrictedRPSFactory.RestrictedRPSFactory_SendMore.selector
//         );
//         createGame(initialHash, duration, 0);
//     }

//     function test_GameCreationWithTooManyOpenGames() public {
//         bytes32 initialHash = 0x0;
//         uint8 duration = 1;

//         for (uint8 i; i < MAX_GAMES; i++) {
//             createGame(initialHash, duration, GAME_CREATION_FEE);
//         }
//         vm.expectRevert(
//             RestrictedRPSFactory.RestrictedRPSFactory_TooManyOpenGames.selector
//         );
//         createGame(initialHash, duration, GAME_CREATION_FEE);
//     }

//     // function test_GameCreationWithReset() public {
//     //     bytes32 initialHash = 0x0;
//     //     uint8 duration = 1;

//     //     for (uint8 i; i < MAX_GAMES; i++) {
//     //         createGame(initialHash, duration, GAME_CREATION_FEE);
//     //     }

//     //     // TODO close last game

//     //     uint8 gameId = createGame(initialHash, duration, GAME_CREATION_FEE);
//     //     assert(gameId == 0);
//     // }

//     //////////////////
//     // Game Joining
//     //////////////////
//     function test_JoiningGame() public playersFunded(1) {
//         bytes32 initialHash = 0x0;
//         uint8 duration = 1;
//         (uint8 gameId, ) = createGame(initialHash, duration, GAME_CREATION_FEE);

//         RestrictedRPSGame game = RestrictedRPSGame(
//             restrictedRPSFactory.getGame(gameId)
//         );

//         address player = PLAYERS[0];
//         vm.startPrank(player);
//         uint8 playerId = game.joinGame{
//             value: restrictedRPSFactory.getBasicJoiningCost()
//         }("");
//         vm.stopPrank();

//         RestrictedRPSGame.PlayerState memory playerState = game.getPlayerState(
//             playerId
//         );

//         assert(playerState.player == player);
//         assert(playerState.encryptedHand == 0x0);
//         assert(playerState.nbrStars == NBR_STARS);
//         assert(playerState.nbrStarsLocked == 0);
//         assert(playerState.nbrRockUsed == 0);
//         assert(playerState.nbrPaperUsed == 0);
//         assert(playerState.nbrScissorsUsed == 0);
//     }

//     function test_JoiningGameWithInsufficiantFunds() public playersFunded(1) {
//         bytes32 initialHash = 0x0;
//         uint8 duration = 1;
//         (uint8 gameId,) = createGame(initialHash, duration, GAME_CREATION_FEE);

//         RestrictedRPSGame game = RestrictedRPSGame(
//             restrictedRPSFactory.getGame(gameId)
//         );

//         address player = PLAYERS[0];
//         vm.expectRevert(RestrictedRPSGame.RestrictedRPS_SendMore.selector);
//         vm.prank(player);
//         game.joinGame{value: 1}("");
//     }

//     function test_JoiningAFullGame() public playersFunded(7) {
//         bytes32 initialHash = 0x0;
//         uint8 duration = 1;
//         (uint8 gameId,) = createGame(initialHash, duration, GAME_CREATION_FEE);

//         uint256 joiningCost = restrictedRPSFactory.getBasicJoiningCost();

//         RestrictedRPSGame game = RestrictedRPSGame(
//             restrictedRPSFactory.getGame(gameId)
//         );

//         for (uint8 i; i < 6; i++) {
//             vm.prank(PLAYERS[i]);
//             game.joinGame{value: joiningCost}("");
//         }

//         vm.expectRevert(RestrictedRPSGame.RestrictedRPS_GameFull.selector);
//         vm.prank(PLAYERS[6]);
//         game.joinGame{value: joiningCost}("");
//     }

//     // function test_JoiningANonOpenGame() public playersFunded(1) {
//     //     // TODO
//     //     vm.expectRevert(RestrictedRPSGame.RestrictedRPS_GameNotOpen.selector);
//     // }

//     function test_DealerJoining() public playersFunded(1) {
//         bytes32 initialHash = 0x0;
//         uint8 duration = 1;
//         (uint8 gameId,) = createGame(initialHash, duration, GAME_CREATION_FEE);
//         uint256 joiningCost = restrictedRPSFactory.getBasicJoiningCost();

//         RestrictedRPSGame game = RestrictedRPSGame(
//             restrictedRPSFactory.getGame(gameId)
//         );

//         vm.expectRevert(
//             RestrictedRPSGame.RestrictedRPS_DealerCannotJoin.selector
//         );
//         vm.prank(DEALER);
//         game.joinGame{value: joiningCost}("");
//     }

//     function test_JoiningTwiceSameGame() public playersFunded(7) {
//         RestrictedRPSGame game = createValidGame(4, 1);
//         uint256 joiningCost = restrictedRPSFactory.getBasicJoiningCost();

//         vm.expectRevert(
//             RestrictedRPSGame.RestrictedRPS_PlayerAlreadyJoined.selector
//         );
//         vm.prank(PLAYERS[2]);
//         game.joinGame{value: joiningCost}("");
//     }

//     //////////////////
//     // Game Playing
//     //////////////////
//     function test_offeringAMatch() public playersFunded(2) {
//         // Create Valid Game
//         RestrictedRPSGame game = createValidGame(2, 1);

//         address player1 = PLAYERS[0];

//         // offer match
//         (uint8 matchId, bytes32 hashedCard) = offerMatch(
//             game,
//             player1,
//             uint8(RestrictedRPSGame.Card.SCISSORS),
//             1,
//             2
//         );
//         RestrictedRPSGame.Match memory m = game.getMatch(matchId);
//         RestrictedRPSGame.PlayerState memory playerState = game.getPlayerState(
//             0
//         );

//         assert(m.player1 == 0);
//         assert(m.player1Hash == hashedCard);
//         assert(m.player1Bet == 1);
//         assert(m.player2Bet == 2);
//         assert(m.result == RestrictedRPSGame.MatchState.UNDECIDED);
//         assert(playerState.nbrStarsLocked == 1);
//     }

//     function test_cancellingAMatch() public playersFunded(2) {
//         // Create Valid Game
//         RestrictedRPSGame game = createValidGame(2, 1);

//         address player1 = PLAYERS[0];

//         // offer match
//         (uint8 matchId, ) = offerMatch(
//             game,
//             player1,
//             uint8(RestrictedRPSGame.Card.SCISSORS),
//             1,
//             2
//         );
//         // cancel match
//         vm.prank(player1);
//         game.cancelMatch(matchId);
//         RestrictedRPSGame.Match memory m = game.getMatch(matchId);
//         RestrictedRPSGame.PlayerState memory playerState = game.getPlayerState(
//             0
//         );

//         assert(m.result == RestrictedRPSGame.MatchState.CANCELLED);
//         assert(playerState.nbrStarsLocked == 0);
//     }

//     function test_OfferingTooManyMatches() public playersFunded(2) {
//         // Create Valid Game
//         RestrictedRPSGame game = createValidGame(2, 1);

//         address player1 = PLAYERS[0];

//         // offer match
//         for (uint8 i; i < 20; i++) {
//             (uint8 matchId, ) = offerMatch(
//                 game,
//                 player1,
//                 uint8(RestrictedRPSGame.Card.SCISSORS),
//                 1,
//                 2
//             );
//             vm.prank(player1);
//             game.cancelMatch(matchId);
//         }

//         vm.expectRevert(
//             RestrictedRPSGame
//                 .RestrictedRPS_PlayerHasOfferedTooManyMatches
//                 .selector
//         );
//         offerMatch(game, player1, uint8(RestrictedRPSGame.Card.SCISSORS), 1, 2);
//     }

//     function test_answeringAMatch() public playersFunded(2) {
//         // Create Valid Game
//         RestrictedRPSGame game = createValidGame(2, 1);

//         address player1 = PLAYERS[0];
//         address player2 = PLAYERS[1];

//         // offer match
//         (uint8 matchId, ) = offerMatch(
//             game,
//             player1,
//             uint8(RestrictedRPSGame.Card.SCISSORS),
//             1,
//             2
//         );

//         vm.prank(player2);
//         game.answerMatch(matchId, RestrictedRPSGame.Card.ROCK);

//         RestrictedRPSGame.Match memory m = game.getMatch(matchId);
//         RestrictedRPSGame.PlayerState memory playerState = game.getPlayerState(
//             1
//         );

//         assert(m.player2 == 1);
//         assert(m.player2Card == RestrictedRPSGame.Card.ROCK);
//         assert(m.result == RestrictedRPSGame.MatchState.ANSWERED);
//         assert(playerState.nbrStarsLocked == 2);
//     }
// }
