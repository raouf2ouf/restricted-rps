// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {QRNGConsumer} from "./QRNGConsumer.sol";
import {RestrictedRPSGame} from "./RestrictedRPSGame.sol";

/*
 * @title RestrictedRPS
 * @author raouf2ouf
 * @notice This contract handles games (matches) in the RestrictedRPS game
 */
contract RestrictedRPSFactory is QRNGConsumer {
    ///////////////////
    // Errors
    ///////////////////
    error RestrictedRPSFactory_InvalidGameId(uint256 gameId);
    error RestrictedRPSFactory_PlayerBanned(address player);
    error RestrictedRPSFactory_SendMore();
    error RestrictedRPSFactory_TooManyOpenGames();
    error RestrictedRPSFactory_DurationTooLong();

    ///////////////////
    // Events
    ///////////////////
    event GameCreated(uint256 indexed gameId, address indexed gameAddress);
    event GameJoined(uint256 indexed gameId, address player);

    ///////////////////
    // Types
    ///////////////////

    ///////////////////
    // State Variables
    ///////////////////
    uint8 private constant NBR_GAMES = 100;
    uint8 private constant MAX_DURATION = 74;
    uint8 private constant NBR_STARS = 3;

    uint8 private constant CARDS_PER_PLAYER = 6;
    uint8 private constant MAX_PLAYERS = 6;
    uint8 private constant MAX_NBR_CARDS = CARDS_PER_PLAYER * MAX_PLAYERS;
    uint8 private constant NBR_CARDS_PER_TYPE = MAX_NBR_CARDS / 3;
    uint8 private constant NBR_BITS_PER_CARD = 2;
    uint8 private constant NBR_CARDS_PER_BYTE = 8 / NBR_BITS_PER_CARD;

    uint256 private s_gameCreationFee = 0; // 0
    uint8 private s_winningsCut = 10; // 0.01%
    uint256 private s_starCost = 1e13; // 0.00001
    uint256 private s_1MCachCost = 1e13; // 0.00001

    uint8 private _nbrOpenGames;

    /// @dev Mapping of banned players
    mapping(address player => bool banned) private s_banned;

    /// @dev games (100 games history)
    address[NBR_GAMES] private s_games;
    uint8 private s_lastGameId = NBR_GAMES - 1;

    ///////////////////
    // Modifiers
    ///////////////////
    modifier isValidGameId(uint256 _gameId) {
        if (_gameId >= NBR_GAMES || s_games[_gameId] == address(0)) {
            revert RestrictedRPSFactory_InvalidGameId(_gameId);
        }
        _;
    }
    modifier isNotBanned() {
        if (s_banned[msg.sender]) {
            revert RestrictedRPSFactory_PlayerBanned(msg.sender);
        }
        _;
    }

    ///////////////////
    // Constructor
    ///////////////////
    constructor(address owner, address airnodeRrp) QRNGConsumer(owner, airnodeRrp)  {}

    ///////////////////
    // Getters
    ///////////////////
    function getBasicJoiningCost() public view returns (uint256) {
        return (s_starCost * NBR_STARS);
    }

    function getGame(uint256 _gameId) external view returns (address) {
        return address(s_games[_gameId]);
    }

    function getGames() external view returns (address[NBR_GAMES] memory) {
        return s_games;
    }

    function getOpenGames() public view returns (address[] memory) {
        uint8 nbrOpenGames = _nbrOpenGames;
        address[] memory result = new address[](nbrOpenGames);
        uint8 j;
        for (uint8 i; i < NBR_GAMES; i++) {
            address adr = s_games[i];
            if (adr != address(0)) {
                RestrictedRPSGame game = RestrictedRPSGame(adr);
                if (game.isOpen()) {
                    result[j] = adr;
                    j++;
                    if (j >= nbrOpenGames) {
                        break;
                    }
                }
            }
        }
        return result;
    }

    function isBanned(address _user) external view returns (bool) {
        return s_banned[_user];
    }

    ///////////////////
    // Setters
    ///////////////////
    function setGameCreationFee(uint256 _gameCreationFee) external onlyOwner {
        s_gameCreationFee = _gameCreationFee;
    }

    function setGameJoiningFee(uint8 _winningsCut) external onlyOwner {
        s_winningsCut = _winningsCut;
    }

    function setStarCost(uint256 _starCost) external onlyOwner {
        s_starCost = _starCost;
    }

    ///////////////////
    // Internal Functions
    ///////////////////

    ///////////////////
    // External Functions
    ///////////////////
    /*
     * @param _initialHash: The hash of the initial shuffle of the deck
     */
    function createGame(
        bytes32 _initialHash,
        uint8 _duration
    ) external payable isNotBanned returns (uint8, address) {
        if (msg.value < s_gameCreationFee) {
            revert RestrictedRPSFactory_SendMore();
        }
        uint8 gameId = (s_lastGameId + 1) % NBR_GAMES;
        address gameAddress = s_games[gameId];
        if (address(gameAddress) != address(0)) {
            RestrictedRPSGame game = RestrictedRPSGame(gameAddress);
            if (game.getState() == RestrictedRPSGame.GameState.OPEN) {
                revert RestrictedRPSFactory_TooManyOpenGames();
            } else {
                game.resetGame(
                    s_winningsCut,
                    s_starCost,
                    s_1MCachCost,
                    msg.sender,
                    _initialHash,
                    _duration
                );
            }
        } else {
            RestrictedRPSGame game = new RestrictedRPSGame(
                address(this),
                gameId,
                s_winningsCut,
                s_starCost,
                s_1MCachCost,
                msg.sender,
                _initialHash,
                _duration
            );
            gameAddress = address(game);
            s_games[gameId] = gameAddress;
        }
        s_lastGameId = gameId;
        _nbrOpenGames++;

        // Ask for seed
        makeRequestUint256(gameAddress);

        emit GameCreated(gameId, gameAddress);
        return (gameId, gameAddress);
    }

    function verifyAndCloseGame() external {
        // TODO
        _nbrOpenGames--;
    }

    function resetGame(uint8 _gameId) external onlyOwner {
        // TODO
    }

    function ban(address _user) external onlyOwner {
        s_banned[_user] = true;
    }

    function unban(address _user) external onlyOwner {
        s_banned[_user] = false;
    }

    ///////////////////
    // Public Helper Functions
    ///////////////////
    function generateRandomNumberFromSeed(
        uint256 _seed,
        uint8 range
    ) public pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(_seed))) % range;
    }

    function getCard(bytes9 _deck, uint8 _index) public pure returns (uint8) {
        uint8 shiftAmount = uint8(
            (_index % NBR_CARDS_PER_BYTE) * NBR_BITS_PER_CARD
        );
        return uint8((uint72(_deck) >> shiftAmount) & 0x03);
    }

    function setCard(
        bytes9 _deck,
        uint8 _index,
        uint8 _card
    ) public pure returns (bytes9) {
        uint8 shiftAmount = uint8(
            (_index % NBR_CARDS_PER_BYTE) * NBR_BITS_PER_CARD
        );
        // clear existing bits
        _deck &= ~(bytes9(uint72(0x03)) << shiftAmount);
        _deck |= bytes9(uint72(_card)) << shiftAmount;
        return _deck;
    }

    function isValidDeck(bytes9 _deck) public pure returns (bool) {
        uint8[3] memory cardCounts;
        for (uint8 i; i < MAX_NBR_CARDS; i++) {
            uint8 cardType = getCard(_deck, i);
            cardCounts[cardType]++;
        }

        return
            cardCounts[0] == NBR_CARDS_PER_TYPE &&
            cardCounts[1] == NBR_CARDS_PER_TYPE &&
            cardCounts[2] == NBR_CARDS_PER_TYPE;
    }

    function getNbrCardsOfPlayer(
        bytes9 _deck,
        uint8 _playerId
    ) public pure returns (int8[3] memory result) {
        uint8 start = _playerId * CARDS_PER_PLAYER;
        for (uint8 i; i < CARDS_PER_PLAYER; i++) {
            uint8 cardIdx = start + i;
            uint8 card = getCard(_deck, cardIdx);
            result[card]++;
        }
    }

    function shuffleDeck(
        bytes9 _deck,
        uint256 _seed
    ) public pure returns (bytes9) {
        for (uint8 i = 35; i > 0; i--) {
            uint8 j = uint8(generateRandomNumberFromSeed(_seed, i + 1));
            // Swap
            uint8 cardI = getCard(_deck, i);
            uint8 cardJ = getCard(_deck, j);

            _deck = setCard(_deck, i, cardJ);
            _deck = setCard(_deck, j, cardI);
        }
        return _deck;
    }
}
