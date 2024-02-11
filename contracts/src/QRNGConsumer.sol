// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;


import {Ownable} from "@openzeppelin/contracts-v4/access/Ownable.sol";
import {RrpRequesterV0} from "@api3/contracts/rrp/requesters/RrpRequesterV0.sol";
import {ISeedable} from "./ISeedable.sol";


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
    constructor(address airnodeRrp) Ownable() RrpRequesterV0(airnodeRrp) {}

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