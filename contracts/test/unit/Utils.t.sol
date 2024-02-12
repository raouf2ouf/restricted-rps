// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import {Test, console2} from "forge-std/Test.sol";
import {RestrictedRPSDeploy} from "../../script/RestrictedRPS.s.sol";
import {RestrictedRPSFactory} from "../../src/RestrictedRPSFactory.sol";
import {RestrictedRPSGame} from "../../src/RestrictedRPSGame.sol";
import {IAirnodeRrpV0} from "@api3/contracts/rrp/interfaces/IAirnodeRrpV0.sol";
// import {AirnodeRrpV0Mock} from "../mock/AirnodeRrpV0Mock.sol";

contract TestUtils is Test {
    RestrictedRPSFactory public restrictedRPSFactory;

    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    uint256 public constant GAME_CREATION_FEE = 1;
    uint8 public constant NBR_GAMES = 20;
    uint8 public constant NBR_STARS = 3;



    address public DEALER = makeAddr("dealer");
    address[] public PLAYERS = [
        makeAddr("player1"),
        makeAddr("player2"),
        makeAddr("player3"),
        makeAddr("player4"),
        makeAddr("player5"),
        makeAddr("player6"),
        makeAddr("player7")
    ];

    function setUp() public {
        RestrictedRPSDeploy restrictedRPSScript = new RestrictedRPSDeploy();
        restrictedRPSFactory = restrictedRPSScript.run();
    }

    modifier dealerFunded() {
        vm.deal(DEALER, STARTING_USER_BALANCE);
        _;
    }

    modifier playersFunded(uint8 nbrPlayers) {
        for (uint8 i; i < nbrPlayers; i++) {
            vm.deal(PLAYERS[i], STARTING_USER_BALANCE);
        }
        _;
    }

    function createGame(
        bytes32 initialHash,
        uint8 duration,
        uint256 fee
    ) public dealerFunded returns (uint8 gameId, address gameAddress) {
        vm.prank(DEALER);
        (gameId, gameAddress) = restrictedRPSFactory.createGame{value: fee}(
                initialHash,
                duration
            );
    }

    function createGameWithPlayers(
        uint8 nbrPlayers,
        uint8 duration
    ) public playersFunded(nbrPlayers) returns (RestrictedRPSGame) {
        bytes9 deck = generateDeck();
        return createGameWithPlayersGivenInitialDeck(deck, nbrPlayers, duration);
    }

    function createGameWithPlayersGivenInitialDeck(bytes9 deck, uint8 nbrPlayers, uint8 duration) public  playersFunded(nbrPlayers)  returns (RestrictedRPSGame game) {
        bytes32 initialHash = hashDeck(deck, "secret");
        (uint8 gameId, ) = createGame(initialHash, duration, GAME_CREATION_FEE);
        uint256 joiningCost = restrictedRPSFactory.getBasicJoiningCost();

        game = RestrictedRPSGame(restrictedRPSFactory.getGame(gameId));

        seedWithRNG(666);

        for (uint8 i; i < nbrPlayers; i++) {
            vm.prank(PLAYERS[i]);
            game.joinGame{value: joiningCost}("");
            vm.prank(DEALER);
            game.setPlayerHand(i, bytes(""));
        }

    }

    function generateDeck() public pure returns (bytes9) {
        bytes9 deck;
        for (uint8 i; i < 36; i++) {
            uint8 card = uint8(i % 3);
            uint8 shiftAmount = uint8(i * 2);
            deck |= bytes9(uint72(card)) << shiftAmount;
        }
        return deck;
    }

    function hashDeck(bytes9 deck, string memory secret) public pure returns (bytes32) {
        return keccak256(bytes.concat(deck, bytes(secret)));
    }

    function hashCard(uint8 card, string memory secret) public pure returns (bytes32) {
        return keccak256(bytes.concat(bytes1(card), bytes(secret)));
    }

    function seedWithRNG(uint256 seed) public {
        IAirnodeRrpV0 airnodeRrp = restrictedRPSFactory.airnodeRrp();
        bytes32 requestId = keccak256(abi.encode(0x1));
        airnodeRrp.fulfill(0, address(0), address(0), 0, abi.encode(seed), abi.encode(0));
    }

    function offerMatch(
        RestrictedRPSGame game,
        address player,
        uint8 card,
        string memory secret,
        uint8 player1Bet,
        uint8 player2Bet
    ) public returns (uint8 matchId, bytes32 hashedCard) {
        // offer a match
        hashedCard = hashCard(card, secret);
        vm.prank(player);
        matchId = game.offerMatch(hashedCard, player1Bet, player2Bet);
    }


    function offerAndAnswerAndCloseMatch(RestrictedRPSGame game, uint8 p1, uint8 p2, uint8 p1Card, uint8 p2Card, string memory secret, uint8 p1Bet, uint8 p2Bet) public returns (uint8 matchId) {
        address player1 = PLAYERS[p1];
        address player2 = PLAYERS[p2];

        // offer match
        (uint8 mId, ) = offerMatch(
            game,
            player1,
            p1Card,
            secret,
            p1Bet,
            p2Bet
        );

        vm.prank(player2);
        game.answerMatch(mId, RestrictedRPSGame.Card(p2Card));

        vm.prank(player1);
        game.closeMatch(mId, p1Card, secret);
        return mId;
    }
}