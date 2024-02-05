// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {RestrictedRPSFactory} from "./RestrictedRPSFactory.sol";

/*
 * @title RestrictedRPS
 * @author raouf2ouf
 * @notice This contract handles games (matches) in the RestrictedRPS game
 */
contract RestrictedRPSGame {
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
    // State Variables
    ///////////////////

    // Constants
    uint8 private constant CARDS_PER_PLAYER = 6;
    uint8 private constant MAX_PLAYERS = 6;
    uint8 private constant NBR_STARS = 3;
    uint8 private constant MAX_OFFERED_MATCHES_PER_PLAYER = 20;
    uint8 private constant MAX_OFFERED_MATCHES =
        MAX_OFFERED_MATCHES_PER_PLAYER * MAX_PLAYERS;

    uint8 private constant NBR_BITS_PER_CARD = 2;
    uint8 private constant NBR_CARDS_PER_BYTE = 8 / NBR_BITS_PER_CARD;

    // Immutables
    RestrictedRPSFactory private immutable i_factory;
    uint8 private immutable i_gameId;

    // State
    uint8 private s_winningsCut = 10;
    uint256 private s_starCost = 1;
    uint256 private s_1MCashCost = 1e14; // 0.0001

    address private s_dealer;
    bytes32 private s_initialHash;
    uint256 private s_seed;
    uint256 private s_startTimestamp;
    uint256 private s_requestId;
    uint8 private s_duration;
    uint8 private s_nbrPlayers;
    GameState private s_state;
    PlayerState[MAX_PLAYERS] s_players;

    uint8 s_nbrMatches;
    Match[MAX_OFFERED_MATCHES] s_matches;

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
    // Modifiers
    ///////////////////
    modifier isNotBanned() {
        if (i_factory.isBanned(msg.sender)) {
            revert RestrictedRPS_PlayerBanned();
        }
        _;
    }
    modifier onlyDealer() {
        if (s_dealer != msg.sender) {
            revert RestrictedRPS_OnlyDealer();
        }
        _;
    }

    modifier onlyFactory() {
        if (msg.sender != address(i_factory)) {
            revert RestrictedRPS_OnlyFactory();
        }
        _;
    }

    modifier isValidPlayerId(uint8 _playerId) {
        if (_playerId >= s_nbrPlayers) {
            revert RestrictedRPS_InvalidPlayerId();
        }
        _;
    }

    modifier isValidMatchId(uint8 _matchId) {
        if (_matchId >= s_nbrMatches) {
            revert RestrictedRPS_InvalidMatchId();
        }
        _;
    }

    ///////////////////
    // Constructor
    ///////////////////
    constructor(
        address _factory,
        uint8 _gameId,
        uint8 _winningsCut,
        uint256 _starCost,
        uint256 _1MCashCost,
        address _dealer,
        bytes32 _initialHash,
        uint8 _duration
    ) {
        i_factory = RestrictedRPSFactory(_factory);
        i_gameId = _gameId;
        _setGame(
            _winningsCut,
            _starCost,
            _1MCashCost,
            _dealer,
            _initialHash,
            _duration
        );
    }

    ///////////////////
    // Getters
    ///////////////////
    function getGameId() external view returns (uint8) {
        return i_gameId;
    }

    function getState() external view returns (GameState) {
        return s_state;
    }

    function getDealer() external view returns (address) {
        return s_dealer;
    }

    function getInitialHash() external view returns (bytes32) {
        return s_initialHash;
    }

    function getDuration() external view returns (uint8) {
        return s_duration;
    }

    function getNbrPlayers() external view returns (uint8) {
        return s_nbrPlayers;
    }

    function getBasicJoiningCost() public view returns (uint256) {
        return (s_starCost * NBR_STARS);
    }

    function getPlayerState(
        uint8 _playerId
    ) external view isValidPlayerId(_playerId) returns (PlayerState memory) {
        return s_players[_playerId];
    }

    function getPlayersState() external view returns (PlayerState[] memory) {
        uint8 nbrPlayers = s_nbrPlayers;
        PlayerState[] memory playersStates = new PlayerState[](nbrPlayers);
        for(uint8 i; i < nbrPlayers; i++) {
            playersStates[i] = s_players[i];
        }
        return playersStates;
    }

    function getPlayerId(
        address playerAddress
    ) public view returns (int8 playerId) {
        playerId = -1;
        uint8 nbrPlayers = s_nbrPlayers;
        for (uint8 i; i < nbrPlayers; i++) {
            if (s_players[i].player == playerAddress) {
                playerId = int8(i);
                break;
            }
        }
    }

    function getMatch(
        uint8 _matchId
    ) external view isValidMatchId(_matchId) returns (Match memory) {
        return s_matches[_matchId];
    }

    function getMatches() external view returns (Match[] memory) {
        uint8 nbrMatches = s_nbrMatches;
        Match[] memory matches = new Match[](nbrMatches);
        for(uint8 i; i < nbrMatches; i++) {
            matches[i] = s_matches[i];
        }
        return matches;
    }

    function isOpen() public view returns (bool) {
        return s_state == GameState.OPEN;
    }

    function getGameInfo()
        public
        view
        returns (uint8, uint8, uint8, uint8, uint256, uint256, address[] memory)
    {
        uint8 nbrPlayers = s_nbrPlayers;
        address[] memory players = new address[](nbrPlayers);
        for (uint8 i; i < nbrPlayers; i++) {
            players[i] = s_players[i].player;
        }
        return (
            i_gameId,
            s_nbrPlayers,
            s_nbrMatches,
            s_duration,
            s_starCost,
            s_1MCashCost,
            players
        );
    }

    ///////////////////
    // Private Functions
    ///////////////////
    function _setGame(
        uint8 _winningsCut,
        uint256 _starCost,
        uint256 _1MCashCost,
        address _dealer,
        bytes32 _initialHash,
        uint8 _duration
    ) private {
        s_winningsCut = _winningsCut;
        s_starCost = _starCost;
        s_1MCashCost = _1MCashCost;
        s_dealer = _dealer;
        s_initialHash = _initialHash;
        s_duration = _duration;
        s_seed = 0;
        s_state = GameState.OPEN;
    }

    function _playCard(uint8 _playerId, Card _card) private {
        if (_card == Card.ROCK) {
            s_players[_playerId].nbrRockUsed++;
        } else if (_card == Card.PAPER) {
            s_players[_playerId].nbrPaperUsed++;
        } else if (_card == Card.SCISSORS) {
            s_players[_playerId].nbrScissorsUsed++;
        }
        s_players[_playerId].nbrCards--;
    }

    function _markAsDraw(
        uint8 _matchId,
        uint8 _player1Id,
        uint8 _player2Id
    ) private {
        Match memory m = s_matches[_matchId];
        s_matches[_matchId].result = MatchState.DRAW;
        s_players[_player1Id].nbrStarsLocked -= m.player1Bet;
        s_players[_player2Id].nbrStarsLocked -= m.player2Bet;
    }

    function _markAsPlayer1Win(
        uint8 _matchId,
        uint8 _player1Id,
        uint8 _player2Id
    ) private {
        Match memory m = s_matches[_matchId];
        s_matches[_matchId].result = MatchState.WIN1;
        s_players[_player1Id].nbrStarsLocked -= m.player1Bet;
        s_players[_player1Id].nbrStars += m.player2Bet;
        s_players[_player2Id].nbrStarsLocked -= m.player2Bet;
        s_players[_player2Id].nbrStars -= m.player2Bet;
    }

    function _markAsPlayer2Win(
        uint8 _matchId,
        uint8 _player1Id,
        uint8 _player2Id
    ) private {
        Match memory m = s_matches[_matchId];
        s_matches[_matchId].result = MatchState.WIN2;
        s_players[_player1Id].nbrStarsLocked -= m.player1Bet;
        s_players[_player1Id].nbrStars -= m.player1Bet;
        s_players[_player2Id].nbrStarsLocked -= m.player2Bet;
        s_players[_player2Id].nbrStars += m.player1Bet;
    }

    function _dealerCheated() private {}

    function _playerCheated(uint8 playerId) private {}

    ///////////////////
    // External Functions
    ///////////////////
    function resetGame(
        uint8 _winningsCut,
        uint256 _starCost,
        uint256 _1MCashCost,
        address _dealer,
        bytes32 _initialHash,
        uint8 _duration
    ) external onlyFactory {
        if (s_state == GameState.OPEN) {
            revert RestrictedRPS_CannotResetOpenGame();
        }
        s_nbrMatches = 0;
        delete s_matches;
        s_nbrPlayers = 0;
        delete s_players;
        _setGame(
            _winningsCut,
            _starCost,
            _1MCashCost,
            _dealer,
            _initialHash,
            _duration
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
        if (s_state != GameState.OPEN) {
            revert RestrictedRPS_GameNotOpen();
        }
        if (s_dealer == player) {
            revert RestrictedRPS_DealerCannotJoin();
        }

        playerId = s_nbrPlayers;
        if ((playerId + 1) > MAX_PLAYERS) {
            revert RestrictedRPS_GameFull();
        }

        // Make sure he has not already joined
        for (uint8 i; i < playerId; i++) {
            if (s_players[i].player == player) {
                revert RestrictedRPS_PlayerAlreadyJoined();
            }
        }

        PlayerState memory playerState;
        playerState.player = player;
        playerState.nbrStars = NBR_STARS;

        // Join game
        s_players[playerId] = playerState;
        s_nbrPlayers++;

        emit GameJoined(playerId, player, pub);
    }

    function setSeed(uint256 seed) external {
        s_seed = seed;
        emit SeedSet(seed);
    }

    function setPlayerHand(
        uint8 _playerId,
        bytes memory encryptedHand
    ) external isValidPlayerId(_playerId) onlyDealer {
        s_players[_playerId].nbrCards = int8(CARDS_PER_PLAYER);
        emit PlayerWasGivenHand(s_players[_playerId].player, encryptedHand);
    }

    function offerMatch(
        bytes32 _hashedCard,
        uint8 _player1Bet,
        uint8 _player2Bet
    ) external returns (uint8 matchId) {
        Match memory m;
        int8 id = getPlayerId(msg.sender);
        if (id == -1) {
            revert RestrictedRPS_NotAPlayer();
        }
        uint8 playerId = uint8(id);

        PlayerState memory player1State = s_players[playerId];

        uint8 nbrOfferedMatches = player1State.nbrOfferedMatches + 1;
        if (nbrOfferedMatches > MAX_OFFERED_MATCHES_PER_PLAYER) {
            revert RestrictedRPS_PlayerHasOfferedTooManyMatches();
        }

        if (
            (_player1Bet + player1State.nbrStarsLocked) >
            (player1State.nbrStars)
        ) {
            revert RestrictedRPS_NotEnoughAvailableStars();
        }

        m.player1 = playerId;
        m.player1Hash = _hashedCard;
        m.player2Bet = _player2Bet;
        m.player1Bet = _player1Bet;
        matchId = s_nbrMatches;
        s_matches[matchId] = m;
        s_nbrMatches++;

        s_players[playerId].nbrOfferedMatches = nbrOfferedMatches;
        s_players[playerId].nbrStarsLocked += _player1Bet;

        emit MatchCreated(matchId, msg.sender);
    }

    function cancelMatch(uint8 _matchId) external isValidMatchId(_matchId) {
        Match memory m = s_matches[_matchId];
        uint8 player1Id = m.player1;
        int8 playerId = getPlayerId(msg.sender);
        if (int8(player1Id) != playerId) {
            revert RestrictedRPS_NotTheRightPlayer();
        }
        MatchState result = m.result;
        if (result != MatchState.UNDECIDED) {
            revert RestrictedRPS_AnsweredMatchCannotBeCancelled();
        }
        s_players[player1Id].nbrStarsLocked -= m.player1Bet;
        s_matches[_matchId].result = MatchState.CANCELLED;

        emit MatchCancelled(_matchId, msg.sender);
    }

    function answerMatch(
        uint8 _matchId,
        Card _card
    ) external isValidMatchId(_matchId) {
        int8 id = getPlayerId(msg.sender);
        if (id == -1) {
            revert RestrictedRPS_NotAPlayer();
        }
        uint8 playerId = uint8(id);
        Match storage m = s_matches[_matchId];
        if (m.result != MatchState.UNDECIDED) {
            revert RestrictedRPS_MatchAlreadyPlayed();
        }
        PlayerState memory player2State = s_players[playerId];

        if (
            (m.player2Bet + player2State.nbrStarsLocked) >
            (player2State.nbrStars)
        ) {
            revert RestrictedRPS_NotEnoughAvailableStars();
        }
        m.player2 = playerId;
        m.player2Card = _card;
        m.result = MatchState.ANSWERED;
        s_players[playerId].nbrStarsLocked += m.player2Bet;
        emit MatchAnswered(_matchId, msg.sender);
    }

    function closeMatch(
        uint8 _matchId,
        uint8 _card,
        string memory _secret
    ) external isValidMatchId(_matchId) {
        Match memory m = s_matches[_matchId];
        if (m.result != MatchState.ANSWERED) {
            revert RestrictedRPS_MatchNotAnswered();
        }
        bytes32 cardHash = keccak256(
            bytes.concat(bytes1(_card), bytes(_secret))
        );
        if (m.player1Hash != cardHash) {
            revert RestrictedRPS_WrongCardHash();
        }

        Card player1Card = Card(_card);
        s_matches[_matchId].player1Card = player1Card;
        Card player2Card = m.player2Card;

        _playCard(m.player1, player1Card);
        _playCard(m.player2, player2Card);

        MatchState mstate = MatchState.UNDECIDED;
        if (uint8(player1Card) > 2) {
            // player 1 played invalid card. Player 2 wins
            _markAsPlayer2Win(_matchId, m.player1, m.player2);
            mstate = MatchState.WIN2;
        }
        if (uint8(player2Card) > 2) {
            // player 2 played invalid card. Player 1 wins
            _markAsPlayer1Win(_matchId, m.player1, m.player2);
            mstate = MatchState.WIN1;
        }

        if (player1Card == player2Card) {
            // Draw
            _markAsDraw(_matchId, m.player1, m.player2);
            mstate = MatchState.DRAW;
        } else if (
            (player1Card == Card.ROCK && player2Card == Card.SCISSORS) ||
            (player1Card == Card.PAPER && player2Card == Card.ROCK) ||
            (player1Card == Card.SCISSORS && player2Card == Card.PAPER)
        ) {
            _markAsPlayer1Win(_matchId, m.player1, m.player2);
            mstate = MatchState.WIN1;
        } else {
            _markAsPlayer2Win(_matchId, m.player1, m.player2);
            mstate = MatchState.WIN2;
        }

        emit MatchClosed(_matchId, uint8(mstate));
    }

    function verifyDealerHonesty(
        bytes9 _initialDeck,
        string memory _secret
    ) public onlyDealer returns (bool) {
        bytes32 hashedDeck = keccak256(
            bytes.concat(_initialDeck, bytes(_secret))
        );
        if (s_initialHash != hashedDeck) {
            revert RestrictedRPS_DeckAndSecretNotMatchingInitialHash();
        }

        if (!i_factory.isValidDeck(_initialDeck)) {
            // TODO Dealer Cheated!!!!!
            emit DealerCheated(s_dealer);
            return false;
        }

        bytes9 shuffledDeck = i_factory.shuffleDeck(_initialDeck, s_seed);

        // TODO: The dealer could send the wrong hand to a player
        // We need to find a way to check that the player recieved the correct hand.
        // verify player hands given by dealer
        for (uint8 i; i < s_nbrPlayers; i++) {
            int8[3] memory cards = i_factory.getNbrCardsOfPlayer(
                shuffledDeck,
                i
            );
            s_players[i].initialNbrRocks = cards[0];
            s_players[i].initialNbrPapers = cards[1];
            s_players[i].initialNbrScissors = cards[1];
        }

        return true;
    }

    function verifyPlayerHonesty(
        uint8 _playerId
    ) public isValidPlayerId(_playerId) returns (bool) {
        PlayerState memory playerState = s_players[_playerId];
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
        for (uint8 i; i < s_nbrPlayers; i++) {
            verifyPlayerHonesty(i);
        }
    }

    function verifyGame() external {
        // TODO
    }
}
