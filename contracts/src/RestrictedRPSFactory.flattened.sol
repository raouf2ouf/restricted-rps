// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;



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

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)



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
}







interface ISeedable {
    function setSeed(uint256 seed) external;
}

// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)





/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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










contract QRNGConsumer is Ownable, RrpRequesterV0 {
    ////////////////
    // State
    ////////////////
    address private _airnode;
    bytes32 private _endpointId;
    address private _sponsorWallet;

    mapping(bytes32 requestId => address gameAddress) public requestToGameAddress;

    ////////////////
    // Events
    ////////////////
    event RequestedUint256(bytes32 indexed requestId);
    event ReceivedUint256(bytes32 indexed requestId, uint256 response);
    event WithdrawalRequested(address indexed airnode, address indexed sponsorWallet);

    ////////////////
    // Errors
    ////////////////
    error GameDoesNotExist();

    ////////////////
    // Construcor
    ////////////////
    constructor(address airnodeRrpAddress) Ownable() RrpRequesterV0(airnodeRrpAddress) {}

    ////////////////
    // External
    ////////////////
    function getRequestParameters() external view returns (address, bytes32, address) {
        return (_airnode, _endpointId, _sponsorWallet);
    }

    function setRequestParameters(
        address airnode,
        bytes32 endpointId,
        address sponsorWallet
    ) external onlyOwner {
        _airnode = airnode;
        _endpointId = endpointId;
        _sponsorWallet = sponsorWallet;
    }

    function fulfillUint256(bytes32 requestId, bytes calldata data) external onlyAirnodeRrp {
        address gameAddress = requestToGameAddress[requestId];
        if(gameAddress == address(0)) {
            revert GameDoesNotExist();
        }
        
        uint256 seed = abi.decode(data, (uint256));
        ISeedable(gameAddress).setSeed(seed);
        emit ReceivedUint256(requestId, seed);
    }

    ////////////////
    // Public
    ////////////////

    ////////////////
    // Internal
    ////////////////
    function _makeRequestUint256(address gameAddress) internal {
        bytes32 requestId = airnodeRrp.makeFullRequest(
            _airnode,
            _endpointId,
            address(this),
            _sponsorWallet,
            address(this),
            this.fulfillUint256.selector,
            "");

        requestToGameAddress[requestId] = gameAddress;
        emit RequestedUint256(requestId);
    }

    ////////////////
    // Private
    ////////////////
}







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
        uint256 paidAmount;
        uint256 rewards;
        uint256 amountToPay;
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
        bool cheated;
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
        DEALER_CHEATED,
        DEALER_HONESTY_PROVEN,
        COMPUTED_REWARDS,
        CLOSED
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
    uint8 private _winningsCut;
    uint256 private _starCost;
    uint256 private _m1CashCost;

    address private _dealer;
    bytes32 private _initialHash;
    uint256 private _seed;
    uint256 private _endTimestamp;
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

    event GameClosed(uint8 indexed state);
    event ComputedRewards();

    ///////////////////
    // Errors
    ///////////////////
    error RestrictedRPS_OnlyFactory();

    error RestrictedRPS_GameNotOpen();
    error RestrictedRPS_GameNotClosed();
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
    error RestrictedRPS_CannotAnswerYourOwnMatch();

    error RestrictedRPS_NotExpectingSeed();
    error RestrictedRPS_DealerHonestyNotYetProven();
    error RestrictedRPS_GameNotClosable();
    error RestrictedRPS_GameNotReadyToVerify();

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

    modifier isClosed() {
        if(_state != GameState.CLOSED) {
            revert RestrictedRPS_GameNotClosed();
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

    function getStarCost() public view returns (uint256) {
        return _starCost;
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

    // function getMatch(
    //     uint8 matchId
    // ) external view isValidMatchId(matchId) returns (Match memory) {
    //     return _matches[matchId];
    // }

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
        returns (uint8, uint8, uint8, uint256, uint256, uint256, address[] memory)
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
            _starCost,
            _m1CashCost,
            _endTimestamp,
            players
        );
    }

    function getEnd() public view returns (uint256) {
        return _endTimestamp;
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
        _endTimestamp = block.timestamp + (duration * 1 days);
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


    function _payPlayersTheirCollateral() private {
        uint8 nbrPlayers = _nbrPlayers;
        for(uint8 i; i < nbrPlayers; i++) {
            _players[i].amountToPay = _players[i].paidAmount;
        }
    }

    function _payPlayersTheirRewards() private {
        uint8 nbrPlayers = _nbrPlayers;
        for(uint8 i; i < nbrPlayers; i++) {
            _players[i].amountToPay = _players[i].rewards;
        }
    }

    function _computeRewardsForPlayer(int8 nbrCards, uint8 nbrStars) private view returns (uint256 payout) {
        if(nbrCards < 0) {
            return 0;
        }
        if(nbrCards != 0) { // player still has cards, limit payout to 4
            if(nbrStars > 4) {
                nbrStars = 4;
            }
        }
        uint256 pay = nbrStars * _starCost; 
        payout = (pay * (1000 - _winningsCut)) / 1000;
    }

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
        if (_state != GameState.CLOSED) {
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
        playerState.paidAmount = msg.value;

        // Join game
        _players[playerId] = playerState;
        _nbrPlayers++;

        emit GameJoined(playerId, player, pub);
    }

    function getSeed() external view returns (uint256) {
        return _seed;
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
        if (playerId == m.player1) {
            revert RestrictedRPS_CannotAnswerYourOwnMatch();
        }
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


    function isReadyToVerify() public view returns(bool) {
        if(_state != GameState.OPEN) {
            return false;
        }
        if(_endTimestamp > block.timestamp) {
            if(_nbrPlayers == 6) {
                PlayerState[6] memory players = _players ;
                for(uint8 i; i < 6; i++) {
                    if(players[i].nbrCards > 0) {
                        return false; //there is still players with cards
                    }
                }
            }
        }
        return true;
    }


    function verifyDealerHonesty(
        bytes9 initialDeck,
        string memory secret
    ) external onlyDealer returns (bool) {
        bool ready = isReadyToVerify();
        if(!ready) {
            revert RestrictedRPS_GameNotReadyToVerify();
        }
        bytes32 hashedDeck = keccak256(
            bytes.concat(initialDeck, bytes(secret))
        );
        if (_initialHash != hashedDeck) {
            revert RestrictedRPS_DeckAndSecretNotMatchingInitialHash();
        }

        if (!_factory.isValidDeck(initialDeck)) {
            // TODO Dealer Cheated!!!!!
            _state = GameState.DEALER_CHEATED;
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
            _players[i].initialNbrScissors = cards[2];
        }

        _state = GameState.DEALER_HONESTY_PROVEN;
        return true;
    }


    function computeRewards() external {
        if(_state != GameState.DEALER_HONESTY_PROVEN) {
            revert RestrictedRPS_DealerHonestyNotYetProven();
        }
        uint8 nbrPlayers = _nbrPlayers;
        uint8 nbrPlayersWhoCheated;
        for(uint8 i; i < nbrPlayers; i++) {
            PlayerState memory playerState = _players[i];
            if (
                (playerState.nbrCards < 0) ||
                (playerState.nbrRockUsed > playerState.initialNbrRocks) ||
                (playerState.nbrPaperUsed > playerState.initialNbrPapers) ||
                (playerState.nbrScissorsUsed > playerState.initialNbrScissors)
            ) {
                emit PlayerCheated(playerState.player);
                nbrPlayersWhoCheated++;
                _players[i].cheated = true;
            } else {
                _players[i].rewards = _computeRewardsForPlayer(playerState.nbrCards, playerState.nbrStars); 
            }
        }
        if(nbrPlayersWhoCheated > 0) { // some players have cheated, give everyone his collateral back
            for(uint8 i; i < nbrPlayers; i++) {
                PlayerState memory playerState = _players[i];
                if (!playerState.cheated) {
                    _players[i].rewards = playerState.paidAmount; 
                }
            }
        }
        _state = GameState.COMPUTED_REWARDS;
        emit ComputedRewards();
    }


    function computeCurrentRewardsForPlayer(uint8 playerId) public view isValidPlayerId(playerId) returns (uint256 payout) {
        PlayerState memory playerState = _players[playerId];
        int8 nbrCards = playerState.nbrCards;
        uint8 nbrStars = playerState.nbrStars;
        payout = _computeRewardsForPlayer(nbrCards, nbrStars);
    }


    function closeGame() external {
        GameState state = _state;
        if(state == GameState.DEALER_CHEATED || (state == GameState.OPEN && block.timestamp >= (_endTimestamp + 1 days))) {
            _payPlayersTheirCollateral();
            _state = GameState.CLOSED;
            emit GameClosed(uint8(state));
        } else if(_state == GameState.COMPUTED_REWARDS) {
            _payPlayersTheirRewards();
            _state = GameState.CLOSED;
            emit GameClosed(uint8(state));
        } else {
            revert RestrictedRPS_GameNotClosable();
        }
    }

    function payPlayers() external isClosed {
        uint8 nbrPlayers = _nbrPlayers;
        for(uint8 i; i < nbrPlayers; i++) {
            uint256 amount = _players[i].amountToPay;
            address playerAddress = _players[i].player;
            if(amount > 0) {
                _players[i].amountToPay = 0;
                payable(playerAddress).transfer(amount);
            }
        }
    }

    function withdraw() external isClosed onlyFactory() {
        payable(address(_factory)).transfer(address(this).balance);
    }
}







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
    uint8 private _winningsCut = 1; // per 1000
    uint256 private _starCost = 1e13; // 0.00001
    uint256 private _m1CachCost = 1e13; // 0.00001


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
        address[] memory all = new address[](_NBR_GAMES);
        uint8 j;
        for (uint8 i; i < _NBR_GAMES; i++) {
            address adr = _games[i];
            if (adr != address(0)) {
                RestrictedRPSGame game = RestrictedRPSGame(adr);
                if (game.isOpen()) {
                    all[j] = adr;
                    j++;
                }
            }
        }
        address [] memory result = new address[](j);
        for(uint8 i; i < j; i++) {
            result[i] = all[i];
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
    ) external payable isNotBanned returns (uint8 gameId, address gameAddress) {
        if (msg.value < _gameCreationFee) {
            revert RestrictedRPSFactory_SendMore();
        }
        gameId = (_lastGameId + 1) % _NBR_GAMES;
        gameAddress = _games[gameId];
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

        // Ask for seed
        _makeRequestUint256(gameAddress);

        emit GameCreated(gameId, gameAddress);
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function withdrawGameCut(uint8 gameId) external onlyOwner {
        RestrictedRPSGame game = RestrictedRPSGame(_games[gameId]);
        game.withdraw();
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
        uint8 byteOffset = 8 - index / _NBR_CARDS_PER_BYTE;
        uint8 bitOffset = uint8(
            (index % _NBR_CARDS_PER_BYTE) * _NBR_BITS_PER_CARD
        );
        return (uint8(deck[byteOffset]) >> bitOffset) & 0x03;
    }

    function setCard(
        bytes9 deck,
        uint8 index,
        uint8 card
    ) public pure returns (bytes9) {
        uint8 bitOffset = uint8(
            index * _NBR_BITS_PER_CARD
        );
        // clear existing bits
        deck &= ~(bytes9(0x000000000000000003) << (bitOffset));
        deck |= bytes9(uint72(card)) << bitOffset;
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
