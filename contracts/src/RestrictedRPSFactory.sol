// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {QRNGConsumer} from "./QRNGConsumer.sol";
import {RestrictedRPSGame} from "./RestrictedRPSGame.sol";

/*
 * @title RestrictedRPS
 * @author raouf2ouf
 * @notice This contract handles games (matches) in the RestrictedRPS game
 */
contract RestrictedRPSFactory is QRNGConsumer {
    ///////////////////
    // Types
    ///////////////////

    ////////////////
    // State
    ////////////////
    uint8 private constant _NBR_GAMES = 20;
    uint8 private constant _MAX_DURATION = 74; // three days
    uint8 private constant _NBR_STARS = 3;

    uint8 private constant _CARDS_PER_PLAYER = 6;
    uint8 private constant _MAX_PLAYERS = 6;
    uint8 private constant _MAX_NBR_CARDS = _CARDS_PER_PLAYER * _MAX_PLAYERS;
    uint8 private constant _NBR_CARDS_PER_TYPE = _MAX_NBR_CARDS / 3;
    uint8 private constant _NBR_BITS_PER_CARD = 2;
    uint8 private constant _NBR_CARDS_PER_BYTE = 8 / _NBR_BITS_PER_CARD;

    uint256 private _gameCreationFee = 1; // 0
    uint8 private _winningsCut = 1; // 0.001 (0.1%) 100% is 1000
    uint256 private _starCost = 1e13; // 0.00001
    uint256 private _m1CachCost = 1e13; // 0.00001

    uint8 private _nbrOpenGames;

    /// @dev Mapping of banned players
    mapping(address player => bool banned) private _banned;

    /// @dev games (100 games history)
    address[_NBR_GAMES] private _games;
    uint8 private _lastGameId = _NBR_GAMES - 1;

    ////////////////
    // Events
    ////////////////
    event GameCreated(uint256 indexed gameId, address indexed gameAddress);
    event GameJoined(uint256 indexed gameId, address player);

    ////////////////
    // Errors
    ////////////////
    error RestrictedRPSFactory_InvalidGameId(uint256 gameId);
    error RestrictedRPSFactory_PlayerBanned(address player);
    error RestrictedRPSFactory_SendMore();
    error RestrictedRPSFactory_TooManyOpenGames();
    error RestrictedRPSFactory_DurationTooLong();

    ////////////////
    // Construcor
    ////////////////
    constructor(address airnodeRrp) QRNGConsumer(airnodeRrp)  {}

    ///////////////////
    // Modifiers
    ///////////////////
    modifier isValidGameId(uint256 gameId) {
        if (gameId >= _NBR_GAMES || _games[gameId] == address(0)) {
            revert RestrictedRPSFactory_InvalidGameId(gameId);
        }
        _;
    }
    modifier isNotBanned() {
        if (_banned[msg.sender]) {
            revert RestrictedRPSFactory_PlayerBanned(msg.sender);
        }
        _;
    }

    ////////////////
    // External
    ////////////////
    function getGame(uint256 gameId) external view returns (address) {
        return address(_games[gameId]);
    }
    function getGames() external view returns (address[_NBR_GAMES] memory) {
        return _games;
    }
    function getOpenGames() public view returns (address[] memory) {
        uint8 nbrOpenGames = _nbrOpenGames;
        address[] memory result = new address[](nbrOpenGames);
        uint8 j;
        for (uint8 i; i < _NBR_GAMES; i++) {
            address adr = _games[i];
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

    function getBasicJoiningCost() public view returns (uint256) {
        return (_starCost * _NBR_STARS);
    }

    function isBanned(address user) external view returns (bool) {
        return _banned[user];
    }
    function ban(address user) external onlyOwner {
        _banned[user] = true;
    }

    function unban(address user) external onlyOwner {
        _banned[user] = false;
    }

    function setGameCreationFee(uint256 gameCreationFee) external onlyOwner {
        _gameCreationFee = gameCreationFee;
    }

    function setWinningsCut(uint8 winningsCut) external onlyOwner {
        _winningsCut = winningsCut;
    }

    function setStarCost(uint256 starCost) external onlyOwner {
        _starCost = starCost;
    }

    function createGame(
        bytes32 initialHash,
        uint8 duration
    ) external payable isNotBanned returns (uint8, address) {
        if (msg.value < _gameCreationFee) {
            revert RestrictedRPSFactory_SendMore();
        }
        uint8 gameId = (_lastGameId + 1) % _NBR_GAMES;
        address gameAddress = _games[gameId];
        if (address(gameAddress) != address(0)) {
            RestrictedRPSGame game = RestrictedRPSGame(gameAddress);
            if (game.getState() != RestrictedRPSGame.GameState.CLOSED) {
                revert RestrictedRPSFactory_TooManyOpenGames();
            } else {
                game.resetGame(
                    _winningsCut,
                    _starCost,
                    _m1CachCost,
                    msg.sender,
                    initialHash,
                    duration
                );
            }
        } else {
            RestrictedRPSGame game = new RestrictedRPSGame(
                address(this),
                gameId,
                _winningsCut,
                _starCost,
                _m1CachCost,
                msg.sender,
                initialHash,
                duration
            );
            gameAddress = address(game);
            _games[gameId] = gameAddress;
        }
        _lastGameId = gameId;
        _nbrOpenGames++;

        // Ask for seed
        _makeRequestUint256(gameAddress);

        emit GameCreated(gameId, gameAddress);
        return (gameId, gameAddress);
    }
    function verifyAndCloseGame() external {
        // TODO
        _nbrOpenGames--;
    }

    ////////////////
    // Public
    ////////////////
    function generateRandomNumberFromSeed(
        uint256 seed,
        uint8 range
    ) public pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(seed))) % range;
    }

    function getCard(bytes9 deck, uint8 index) public pure returns (uint8) {
        uint8 shiftAmount = uint8(
            (index % _NBR_CARDS_PER_BYTE) * _NBR_BITS_PER_CARD
        );
        return uint8((uint72(deck) >> shiftAmount) & 0x03);
    }

    function setCard(
        bytes9 deck,
        uint8 index,
        uint8 card
    ) public pure returns (bytes9) {
        uint8 shiftAmount = uint8(
            (index % _NBR_CARDS_PER_BYTE) * _NBR_BITS_PER_CARD
        );
        // clear existing bits
        deck &= ~(bytes9(uint72(0x03)) << shiftAmount);
        deck |= bytes9(uint72(card)) << shiftAmount;
        return deck;
    }

    function isValidDeck(bytes9 deck) public pure returns (bool) {
        uint8[3] memory cardCounts;
        for (uint8 i; i < _MAX_NBR_CARDS; i++) {
            uint8 cardType = getCard(deck, i);
            cardCounts[cardType]++;
        }

        return
            cardCounts[0] == _NBR_CARDS_PER_TYPE &&
            cardCounts[1] == _NBR_CARDS_PER_TYPE &&
            cardCounts[2] == _NBR_CARDS_PER_TYPE;
    }

    function getNbrCardsOfPlayer(
        bytes9 deck,
        uint8 playerId
    ) public pure returns (int8[3] memory result) {
        uint8 start = playerId * _CARDS_PER_PLAYER;
        for (uint8 i; i < _CARDS_PER_PLAYER; i++) {
            uint8 cardIdx = start + i;
            uint8 card = getCard(deck, cardIdx);
            result[card]++;
        }
    }

    function shuffleDeck(
        bytes9 deck,
        uint256 seed
    ) public pure returns (bytes9) {
        for (uint8 i = 35; i > 0; i--) {
            uint8 j = uint8(generateRandomNumberFromSeed(seed, i + 1));
            // Swap
            uint8 cardI = getCard(deck, i);
            uint8 cardJ = getCard(deck, j);

            deck = setCard(deck, i, cardJ);
            deck = setCard(deck, j, cardI);
        }
        return deck;
    }

    ////////////////
    // Internal
    ////////////////

    ////////////////
    // Private
    ////////////////

}
