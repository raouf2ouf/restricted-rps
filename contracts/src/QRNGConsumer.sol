// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;


import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {RrpRequesterV0} from "@api3/contracts/rrp/requesters/RrpRequesterV0.sol";
import {ISeedable} from "./ISeedable.sol";


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