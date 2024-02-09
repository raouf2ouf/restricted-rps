// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {RestrictedRPSFactory} from "./RestrictedRPSFactory.sol";
import {ISeedable} from "./ISeedable.sol";

/*
 * @title RestrictedRPS
 * @author raouf2ouf
 * @notice This contract handles games (matches) in the RestrictedRPS game
 */
contract RestrictedRPSGame is ISeedable {
    ///////////////////
    // Types
    ///////////////////
    struct PlayerState {
        address player;
        bytes32 encryptedHand;
        uint8 nbrStars;
        uint8 nbrStarsLocked;
        int8 nbrCards;
        int8 nbrRockUsed;
        int8 nbrPaperUsed;
        int8 nbrScissorsUsed;
        uint8 nbrOfferedMatches;
        int8 initialNbrRocks; // int8 rather than uint8 to avoid cast
        int8 initialNbrPapers;
        int8 initialNbrScissors;
    }

    struct Match {
        uint8 player1;
        uint8 player2;
        Card player1Card;
        Card player2Card;
        uint8 player1Bet;
        uint8 player2Bet;
        MatchState result;
        bytes32 player1Hash;
    }

    enum GameState {
        OPEN,
        WAITING_FOR_SEED,
        CLOSED,
        INVALID
    }

    enum MatchState {
        UNDECIDED,
        ANSWERED,
        CANCELLED,
        DRAW,
        WIN1, // win for player 1
        WIN2 // win for player 2
    }

    enum Card {
        ROCK,
        PAPER,
        SCISSORS
    }

    ///////////////////
    // State
    ///////////////////

    // Constants
    uint8 private constant _CARDS_PER_PLAYER = 6;
    uint8 private constant _MAX_PLAYERS = 6;
    uint8 private constant _NBR_STARS = 3;
    uint8 private constant _MAX_OFFERED_MATCHES_PER_PLAYER = 20;
    uint8 private constant _MAX_OFFERED_MATCHES =
        _MAX_OFFERED_MATCHES_PER_PLAYER * _MAX_PLAYERS;

    uint8 private constant _NBR_BITS_PER_CARD = 2;
    uint8 private constant _NBR_CARDS_PER_BYTE = 8 / _NBR_BITS_PER_CARD;

    // Immutables
    RestrictedRPSFactory private immutable _factory;
    uint8 private immutable _gameId;

    // State
    uint8 private _winningsCut = 10;
    uint256 private _starCost = 1;
    uint256 private _m1CashCost = 1e14; // 0.0001

    address private _dealer;
    bytes32 private _initialHash;
    uint256 private _seed;
    uint256 private _startTimestamp;
    uint8 private _duration;
    uint8 private _nbrPlayers;
    GameState private _state;
    PlayerState[_MAX_PLAYERS] _players;

    uint8 _nbrMatches;
    Match[_MAX_OFFERED_MATCHES] _matches;

    ///////////////////
    // Events
    ///////////////////
    event GameJoined(uint8 indexed playerId, address indexed player, string);
    event GameStarted();
    event PlayerWasGivenHand(address indexed player, bytes encryptedHand);
    event SeedSet(uint256 seed);

    event MatchCreated(uint256 indexed matchId, address indexed player);
    event MatchAnswered(uint256 indexed matchId, address indexed player);
    event MatchCancelled(uint256 indexed matchId, address indexed player);
    event MatchClosed(uint256 indexed matchId, uint8 indexed state);

    event PlayerCheated(address indexed);
    event DealerCheated(address indexed);

    ///////////////////
    // Errors
    ///////////////////
    error RestrictedRPS_OnlyFactory();

    error RestrictedRPS_GameNotOpen();
    error RestrictedRPS_GameFull();
    error RestrictedRPS_CannotResetOpenGame();

    error RestrictedRPS_SendMore();

    error RestrictedRPS_OnlyDealer();
    error RestrictedRPS_DealerCannotJoin();
    error RestrictedRPS_DeckAndSecretNotMatchingInitialHash();

    error RestrictedRPS_PlayerAlreadyJoined();
    error RestrictedRPS_PlayerBanned();
    error RestrictedRPS_InvalidPlayerId();
    error RestrictedRPS_NotAPlayer();
    error RestrictedRPS_NotTheRightPlayer();

    error RestrictedRPS_InvalidMatchId();
    error RestrictedRPS_MatchAlreadyPlayed();
    error RestrictedRPS_MatchNotAnswered();
    error RestrictedRPS_AnsweredMatchCannotBeCancelled();
    error RestrictedRPS_WrongCardHash();
    error RestrictedRPS_PlayerHasOfferedTooManyMatches();
    error RestrictedRPS_NotEnoughAvailableStars();

    error RestrictedRPS_NotExpectingSeed();

    ///////////////////
    // Constructor
    ///////////////////
    constructor(
        address factory,
        uint8 gameId,
        uint8 winningsCut,
        uint256 starCost,
        uint256 m1CashCost,
        address dealer,
        bytes32 initialHash,
        uint8 duration
    ) {
        _factory = RestrictedRPSFactory(factory);
        _gameId = gameId;
        _setGame(
            winningsCut,
            starCost,
            m1CashCost,
            dealer,
            initialHash,
            duration
        );
    }

    ///////////////////
    // Modifiers
    ///////////////////
    modifier isNotBanned() {
        if (_factory.isBanned(msg.sender)) {
            revert RestrictedRPS_PlayerBanned();
        }
        _;
    }
    modifier onlyDealer() {
        if (_dealer != msg.sender) {
            revert RestrictedRPS_OnlyDealer();
        }
        _;
    }

    modifier onlyFactory() {
        if (msg.sender != address(_factory)) {
            revert RestrictedRPS_OnlyFactory();
        }
        _;
    }

    modifier isValidPlayerId(uint8 playerId) {
        if (playerId >= _nbrPlayers) {
            revert RestrictedRPS_InvalidPlayerId();
        }
        _;
    }

    modifier isValidMatchId(uint8 matchId) {
        if (matchId >= _nbrMatches) {
            revert RestrictedRPS_InvalidMatchId();
        }
        _;
    }


    ///////////////////
    // Getters
    ///////////////////
    function getGameId() external view returns (uint8) {
        return _gameId;
    }

    function getState() external view returns (GameState) {
        return _state;
    }

    function getDealer() external view returns (address) {
        return _dealer;
    }

    function getInitialHash() external view returns (bytes32) {
        return _initialHash;
    }

    function getDuration() external view returns (uint8) {
        return _duration;
    }

    function getNbrPlayers() external view returns (uint8) {
        return _nbrPlayers;
    }

    function getBasicJoiningCost() public view returns (uint256) {
        return (_starCost * _NBR_STARS);
    }

    function getPlayerState(
        uint8 playerId
    ) external view isValidPlayerId(playerId) returns (PlayerState memory) {
        return _players[playerId];
    }

    function getPlayersState() external view returns (PlayerState[] memory) {
        uint8 nbrPlayers = _nbrPlayers;
        PlayerState[] memory playersStates = new PlayerState[](nbrPlayers);
        for(uint8 i; i < nbrPlayers; i++) {
            playersStates[i] = _players[i];
        }
        return playersStates;
    }

    function getPlayerId(
        address playerAddress
    ) public view returns (int8 playerId) {
        playerId = -1;
        uint8 nbrPlayers = _nbrPlayers;
        for (uint8 i; i < nbrPlayers; i++) {
            if (_players[i].player == playerAddress) {
                playerId = int8(i);
                break;
            }
        }
    }

    function getMatch(
        uint8 matchId
    ) external view isValidMatchId(matchId) returns (Match memory) {
        return _matches[matchId];
    }

    function getMatches() external view returns (Match[] memory) {
        uint8 nbrMatches = _nbrMatches;
        Match[] memory matches = new Match[](nbrMatches);
        for(uint8 i; i < nbrMatches; i++) {
            matches[i] = _matches[i];
        }
        return matches;
    }

    function isOpen() public view returns (bool) {
        return _state == GameState.OPEN;
    }

    function getGameInfo()
        public
        view
        returns (uint8, uint8, uint8, uint8, uint256, uint256, address[] memory)
    {
        uint8 nbrPlayers = _nbrPlayers;
        address[] memory players = new address[](nbrPlayers);
        for (uint8 i; i < nbrPlayers; i++) {
            players[i] = _players[i].player;
        }
        return (
            _gameId,
            _nbrPlayers,
            _nbrMatches,
            _duration,
            _starCost,
            _m1CashCost,
            players
        );
    }

    ///////////////////
    // Private Functions
    ///////////////////
    function _setGame(
        uint8 winningsCut,
        uint256 starCost,
        uint256 m1CashCost,
        address dealer,
        bytes32 initialHash,
        uint8 duration
    ) private {
        _winningsCut = winningsCut;
        _starCost = starCost;
        _m1CashCost = m1CashCost;
        _dealer = dealer;
        _initialHash = initialHash;
        _duration = duration;
        _seed = 0;
        _state = GameState.WAITING_FOR_SEED;
    }

    function _playCard(uint8 playerId, Card card) private {
        if (card == Card.ROCK) {
            _players[playerId].nbrRockUsed++;
        } else if (card == Card.PAPER) {
            _players[playerId].nbrPaperUsed++;
        } else if (card == Card.SCISSORS) {
            _players[playerId].nbrScissorsUsed++;
        }
        _players[playerId].nbrCards--;
    }

    function _markAsDraw(
        uint8 matchId,
        uint8 player1Id,
        uint8 player2Id
    ) private {
        Match memory m = _matches[matchId];
        _matches[matchId].result = MatchState.DRAW;
        _players[player1Id].nbrStarsLocked -= m.player1Bet;
        _players[player2Id].nbrStarsLocked -= m.player2Bet;
    }

    function _markAsPlayer1Win(
        uint8 matchId,
        uint8 player1Id,
        uint8 player2Id
    ) private {
        Match memory m = _matches[matchId];
        _matches[matchId].result = MatchState.WIN1;
        _players[player1Id].nbrStarsLocked -= m.player1Bet;
        _players[player1Id].nbrStars += m.player2Bet;
        _players[player2Id].nbrStarsLocked -= m.player2Bet;
        _players[player2Id].nbrStars -= m.player2Bet;
    }

    function _markAsPlayer2Win(
        uint8 matchId,
        uint8 player1Id,
        uint8 player2Id
    ) private {
        Match memory m = _matches[matchId];
        _matches[matchId].result = MatchState.WIN2;
        _players[player1Id].nbrStarsLocked -= m.player1Bet;
        _players[player1Id].nbrStars -= m.player1Bet;
        _players[player2Id].nbrStarsLocked -= m.player2Bet;
        _players[player2Id].nbrStars += m.player1Bet;
    }

    function _dealerCheated() private {}

    function _playerCheated(uint8 playerId) private {}

    ///////////////////
    // External Functions
    ///////////////////
    function resetGame(
        uint8 winningsCut,
        uint256 starCost,
        uint256 m1CashCost,
        address dealer,
        bytes32 initialHash,
        uint8 duration
    ) external onlyFactory {
        if (_state == GameState.OPEN) {
            revert RestrictedRPS_CannotResetOpenGame();
        }
        _nbrMatches = 0;
        delete _matches;
        _nbrPlayers = 0;
        delete _players;
        _setGame(
            winningsCut,
            starCost,
            m1CashCost,
            dealer,
            initialHash,
            duration
        );
    }

    /*
     * @param _initialHash: The hash of the initial shuffle of the deck
     */
    function joinGame(string memory pub) external payable returns (uint8 playerId) {
        address player = msg.sender;
        if (msg.value < getBasicJoiningCost()) {
            revert RestrictedRPS_SendMore();
        }
        if (_state != GameState.OPEN) {
            revert RestrictedRPS_GameNotOpen();
        }
        if (_dealer == player) {
            revert RestrictedRPS_DealerCannotJoin();
        }

        playerId = _nbrPlayers;
        if ((playerId + 1) > _MAX_PLAYERS) {
            revert RestrictedRPS_GameFull();
        }

        // Make sure he has not already joined
        for (uint8 i; i < playerId; i++) {
            if (_players[i].player == player) {
                revert RestrictedRPS_PlayerAlreadyJoined();
            }
        }

        PlayerState memory playerState;
        playerState.player = player;
        playerState.nbrStars = _NBR_STARS;

        // Join game
        _players[playerId] = playerState;
        _nbrPlayers++;

        emit GameJoined(playerId, player, pub);
    }

    function setSeed(uint256 seed) external onlyFactory {
        if(_state != GameState.WAITING_FOR_SEED) {
            revert RestrictedRPS_NotExpectingSeed();
        }
        _seed = seed;
        _state = GameState.OPEN;
        emit SeedSet(seed);
    }

    function setPlayerHand(
        uint8 playerId,
        bytes memory encryptedHand
    ) external isValidPlayerId(playerId) onlyDealer {
        _players[playerId].nbrCards = int8(_CARDS_PER_PLAYER);
        emit PlayerWasGivenHand(_players[playerId].player, encryptedHand);
    }

    function offerMatch(
        bytes32 hashedCard,
        uint8 player1Bet,
        uint8 player2Bet
    ) external returns (uint8 matchId) {
        Match memory m;
        int8 id = getPlayerId(msg.sender);
        if (id == -1) {
            revert RestrictedRPS_NotAPlayer();
        }
        uint8 playerId = uint8(id);

        PlayerState memory player1State = _players[playerId];

        uint8 nbrOfferedMatches = player1State.nbrOfferedMatches + 1;
        if (nbrOfferedMatches > _MAX_OFFERED_MATCHES_PER_PLAYER) {
            revert RestrictedRPS_PlayerHasOfferedTooManyMatches();
        }

        if (
            (player1Bet + player1State.nbrStarsLocked) >
            (player1State.nbrStars)
        ) {
            revert RestrictedRPS_NotEnoughAvailableStars();
        }

        m.player1 = playerId;
        m.player1Hash = hashedCard;
        m.player2Bet = player2Bet;
        m.player1Bet = player1Bet;
        matchId = _nbrMatches;
        _matches[matchId] = m;
        _nbrMatches++;

        _players[playerId].nbrOfferedMatches = nbrOfferedMatches;
        _players[playerId].nbrStarsLocked += player1Bet;

        emit MatchCreated(matchId, msg.sender);
    }

    function cancelMatch(uint8 matchId) external isValidMatchId(matchId) {
        Match memory m = _matches[matchId];
        uint8 player1Id = m.player1;
        int8 playerId = getPlayerId(msg.sender);
        if (int8(player1Id) != playerId) {
            revert RestrictedRPS_NotTheRightPlayer();
        }
        MatchState result = m.result;
        if (result != MatchState.UNDECIDED) {
            revert RestrictedRPS_AnsweredMatchCannotBeCancelled();
        }
        _players[player1Id].nbrStarsLocked -= m.player1Bet;
        _matches[matchId].result = MatchState.CANCELLED;

        emit MatchCancelled(matchId, msg.sender);
    }

    function answerMatch(
        uint8 matchId,
        Card card
    ) external isValidMatchId(matchId) {
        int8 id = getPlayerId(msg.sender);
        if (id == -1) {
            revert RestrictedRPS_NotAPlayer();
        }
        uint8 playerId = uint8(id);
        Match storage m = _matches[matchId];
        if (m.result != MatchState.UNDECIDED) {
            revert RestrictedRPS_MatchAlreadyPlayed();
        }
        PlayerState memory player2State = _players[playerId];

        if (
            (m.player2Bet + player2State.nbrStarsLocked) >
            (player2State.nbrStars)
        ) {
            revert RestrictedRPS_NotEnoughAvailableStars();
        }
        m.player2 = playerId;
        m.player2Card = card;
        m.result = MatchState.ANSWERED;
        _players[playerId].nbrStarsLocked += m.player2Bet;
        emit MatchAnswered(matchId, msg.sender);
    }

    function closeMatch(
        uint8 matchId,
        uint8 card,
        string memory secret
    ) external isValidMatchId(matchId) {
        Match memory m = _matches[matchId];
        if (m.result != MatchState.ANSWERED) {
            revert RestrictedRPS_MatchNotAnswered();
        }
        bytes32 cardHash = keccak256(
            bytes.concat(bytes1(card), bytes(secret))
        );
        if (m.player1Hash != cardHash) {
            revert RestrictedRPS_WrongCardHash();
        }

        Card player1Card = Card(card);
        _matches[matchId].player1Card = player1Card;
        Card player2Card = m.player2Card;

        _playCard(m.player1, player1Card);
        _playCard(m.player2, player2Card);

        MatchState mstate = MatchState.UNDECIDED;
        if (uint8(player1Card) > 2) {
            // player 1 played invalid card. Player 2 wins
            _markAsPlayer2Win(matchId, m.player1, m.player2);
            mstate = MatchState.WIN2;
        }
        if (uint8(player2Card) > 2) {
            // player 2 played invalid card. Player 1 wins
            _markAsPlayer1Win(matchId, m.player1, m.player2);
            mstate = MatchState.WIN1;
        }

        if (player1Card == player2Card) {
            // Draw
            _markAsDraw(matchId, m.player1, m.player2);
            mstate = MatchState.DRAW;
        } else if (
            (player1Card == Card.ROCK && player2Card == Card.SCISSORS) ||
            (player1Card == Card.PAPER && player2Card == Card.ROCK) ||
            (player1Card == Card.SCISSORS && player2Card == Card.PAPER)
        ) {
            _markAsPlayer1Win(matchId, m.player1, m.player2);
            mstate = MatchState.WIN1;
        } else {
            _markAsPlayer2Win(matchId, m.player1, m.player2);
            mstate = MatchState.WIN2;
        }

        emit MatchClosed(matchId, uint8(mstate));
    }

    function verifyDealerHonesty(
        bytes9 initialDeck,
        string memory secret
    ) public onlyDealer returns (bool) {
        bytes32 hashedDeck = keccak256(
            bytes.concat(initialDeck, bytes(secret))
        );
        if (_initialHash != hashedDeck) {
            revert RestrictedRPS_DeckAndSecretNotMatchingInitialHash();
        }

        if (!_factory.isValidDeck(initialDeck)) {
            // TODO Dealer Cheated!!!!!
            emit DealerCheated(_dealer);
            return false;
        }

        bytes9 shuffledDeck = _factory.shuffleDeck(initialDeck, _seed);

        // TODO: The dealer could send the wrong hand to a player
        // We need to find a way to check that the player recieved the correct hand.
        // verify player hands given by dealer
        for (uint8 i; i < _nbrPlayers; i++) {
            int8[3] memory cards = _factory.getNbrCardsOfPlayer(
                shuffledDeck,
                i
            );
            _players[i].initialNbrRocks = cards[0];
            _players[i].initialNbrPapers = cards[1];
            _players[i].initialNbrScissors = cards[1];
        }

        return true;
    }

    function verifyPlayerHonesty(
        uint8 playerId
    ) public isValidPlayerId(playerId) returns (bool) {
        PlayerState memory playerState = _players[playerId];
        if (
            (playerState.nbrRockUsed > playerState.initialNbrRocks) ||
            (playerState.nbrPaperUsed > playerState.initialNbrPapers) ||
            (playerState.nbrScissorsUsed > playerState.initialNbrScissors)
        ) {
            // TODO
            emit PlayerCheated(playerState.player);
            return false;
        }
        return true;
    }

    function verifyPlayersHonesty() public {
        for (uint8 i; i < _nbrPlayers; i++) {
            verifyPlayerHonesty(i);
        }
    }

    function verifyGame() external {
        // TODO
    }
}
