// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;







// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)




// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)



/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}










interface IAuthorizationUtilsV0 {
    function checkAuthorizationStatus(
        address[] calldata authorizers,
        address airnode,
        bytes32 requestId,
        bytes32 endpointId,
        address sponsor,
        address requester
    ) external view returns (bool status);

    function checkAuthorizationStatuses(
        address[] calldata authorizers,
        address airnode,
        bytes32[] calldata requestIds,
        bytes32[] calldata endpointIds,
        address[] calldata sponsors,
        address[] calldata requesters
    ) external view returns (bool[] memory statuses);
}




interface ITemplateUtilsV0 {
    event CreatedTemplate(
        bytes32 indexed templateId,
        address airnode,
        bytes32 endpointId,
        bytes parameters
    );

    function createTemplate(
        address airnode,
        bytes32 endpointId,
        bytes calldata parameters
    ) external returns (bytes32 templateId);

    function getTemplates(bytes32[] calldata templateIds)
        external
        view
        returns (
            address[] memory airnodes,
            bytes32[] memory endpointIds,
            bytes[] memory parameters
        );

    function templates(bytes32 templateId)
        external
        view
        returns (
            address airnode,
            bytes32 endpointId,
            bytes memory parameters
        );
}




interface IWithdrawalUtilsV0 {
    event RequestedWithdrawal(
        address indexed airnode,
        address indexed sponsor,
        bytes32 indexed withdrawalRequestId,
        address sponsorWallet
    );

    event FulfilledWithdrawal(
        address indexed airnode,
        address indexed sponsor,
        bytes32 indexed withdrawalRequestId,
        address sponsorWallet,
        uint256 amount
    );

    function requestWithdrawal(address airnode, address sponsorWallet) external;

    function fulfillWithdrawal(
        bytes32 withdrawalRequestId,
        address airnode,
        address sponsor
    ) external payable;

    function sponsorToWithdrawalRequestCount(address sponsor)
        external
        view
        returns (uint256 withdrawalRequestCount);
}


interface IAirnodeRrpV0 is
    IAuthorizationUtilsV0,
    ITemplateUtilsV0,
    IWithdrawalUtilsV0
{
    event SetSponsorshipStatus(
        address indexed sponsor,
        address indexed requester,
        bool sponsorshipStatus
    );

    event MadeTemplateRequest(
        address indexed airnode,
        bytes32 indexed requestId,
        uint256 requesterRequestCount,
        uint256 chainId,
        address requester,
        bytes32 templateId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes parameters
    );

    event MadeFullRequest(
        address indexed airnode,
        bytes32 indexed requestId,
        uint256 requesterRequestCount,
        uint256 chainId,
        address requester,
        bytes32 endpointId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes parameters
    );

    event FulfilledRequest(
        address indexed airnode,
        bytes32 indexed requestId,
        bytes data
    );

    event FailedRequest(
        address indexed airnode,
        bytes32 indexed requestId,
        string errorMessage
    );

    function setSponsorshipStatus(address requester, bool sponsorshipStatus)
        external;

    function makeTemplateRequest(
        bytes32 templateId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata parameters
    ) external returns (bytes32 requestId);

    function makeFullRequest(
        address airnode,
        bytes32 endpointId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata parameters
    ) external returns (bytes32 requestId);

    function fulfill(
        bytes32 requestId,
        address airnode,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata data,
        bytes calldata signature
    ) external returns (bool callSuccess, bytes memory callData);

    function fail(
        bytes32 requestId,
        address airnode,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        string calldata errorMessage
    ) external;

    function sponsorToRequesterToSponsorshipStatus(
        address sponsor,
        address requester
    ) external view returns (bool sponsorshipStatus);

    function requesterToRequestCountPlusOne(address requester)
        external
        view
        returns (uint256 requestCountPlusOne);

    function requestIsAwaitingFulfillment(bytes32 requestId)
        external
        view
        returns (bool isAwaitingFulfillment);
}


/// @title The contract to be inherited to make Airnode RRP requests
contract RrpRequesterV0 {
    IAirnodeRrpV0 public immutable airnodeRrp;

    /// @dev Reverts if the caller is not the Airnode RRP contract.
    /// Use it as a modifier for fulfill and error callback methods, but also
    /// check `requestId`.
    modifier onlyAirnodeRrp() {
        require(msg.sender == address(airnodeRrp), "Caller not Airnode RRP");
        _;
    }

    /// @dev Airnode RRP address is set at deployment and is immutable.
    /// RrpRequester is made its own sponsor by default. RrpRequester can also
    /// be sponsored by others and use these sponsorships while making
    /// requests, i.e., using this default sponsorship is optional.
    /// @param _airnodeRrp Airnode RRP contract address
    constructor(address _airnodeRrp) {
        airnodeRrp = IAirnodeRrpV0(_airnodeRrp);
        IAirnodeRrpV0(_airnodeRrp).setSponsorshipStatus(address(this), true);
    }
}






interface ISeedable {
    function setSeed(uint256 seed) external;
}


contract QRNGConsumer is Ownable, RrpRequesterV0 {
    error GameDoesNotExist();

    event RequestedUint256(bytes32 indexed requestId);
    event ReceivedUint256(bytes32 indexed requestId, uint256 response);
    event WithdrawalRequested(address indexed airnode, address indexed sponsorWallet);


    address public _airnode;
    bytes32 public _endpointId;
    address public _sponsorWallet;

    mapping(bytes32 requestId => address gameAddress) public _requestToGameAddress;

    constructor(address owner, address airnodeRrp) Ownable(owner) RrpRequesterV0(airnodeRrp) {}

    function setRequestParameters(
        address airnode,
        bytes32 endpointId,
        address sponsorWallet
    ) external onlyOwner {
        _airnode = airnode;
        _endpointId = endpointId;
        _sponsorWallet = sponsorWallet;
    }

    function makeRequestUint256(address gameAddress) internal {
        bytes32 requestId = airnodeRrp.makeFullRequest(
            _airnode,
            _endpointId,
            address(this),
            _sponsorWallet,
            address(this),
            this.fulfillUint256.selector,
            "");

        _requestToGameAddress[requestId] = gameAddress;
        emit RequestedUint256(requestId);
    }

    function fulfillUint256(bytes32 requestId, bytes calldata data) external onlyAirnodeRrp {
        address gameAddress = _requestToGameAddress[requestId];
        if(gameAddress == address(0)) {
            revert GameDoesNotExist();
        }
        
        uint256 seed = abi.decode(data, (uint256));
        ISeedable(gameAddress).setSeed(seed);
        emit ReceivedUint256(requestId, seed);
    }
}







/*
 * @title RestrictedRPS
 * @author raouf2ouf
 * @notice This contract handles games (matches) in the RestrictedRPS game
 */
contract RestrictedRPSGame is ISeedable {
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
    bool private _expectingSeed;
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
        s_state = GameState.CLOSED;
        _expectingSeed = true;
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

    function setSeed(uint256 seed) external onlyFactory {
        if(!_expectingSeed) {
            revert RestrictedRPS_NotExpectingSeed();
        }
        s_seed = seed;
        _expectingSeed = false;
        s_state = GameState.OPEN;
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
