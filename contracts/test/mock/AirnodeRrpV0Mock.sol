
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;


import {Ownable} from "@openzeppelin/contracts-v4/access/Ownable.sol";
import {IAirnodeRrpV0} from "@api3/contracts/rrp/interfaces/IAirnodeRrpV0.sol";

contract AirnodeRrpV0Mock is IAirnodeRrpV0 {
    event fullfillMock(bool indexed, bytes indexed);

    function checkAuthorizationStatus(
        address[] calldata authorizers,
        address airnode,
        bytes32 requestId,
        bytes32 endpointId,
        address sponsor,
        address requester
    ) external view returns (bool status) {}

    function checkAuthorizationStatuses(
        address[] calldata authorizers,
        address airnode,
        bytes32[] calldata requestIds,
        bytes32[] calldata endpointIds,
        address[] calldata sponsors,
        address[] calldata requesters
    ) external view returns (bool[] memory statuses) {}

    function createTemplate(
        address airnode,
        bytes32 endpointId,
        bytes calldata parameters
    ) external returns (bytes32 templateId) {}

    function getTemplates(bytes32[] calldata templateIds)
        external
        view
        returns (
            address[] memory airnodes,
            bytes32[] memory endpointIds,
            bytes[] memory parameters
        ) {}

    function templates(bytes32 templateId)
        external
        view
        returns (
            address airnode,
            bytes32 endpointId,
            bytes memory parameters
        ) {}

    function setSponsorshipStatus(address requester, bool sponsorshipStatus)
        external {

        }

    function makeTemplateRequest(
        bytes32 templateId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata parameters
    ) external returns (bytes32 requestId) {
    }

    function makeFullRequest(
        address airnode,
        bytes32 endpointId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata parameters
    ) external returns (bytes32 requestId) {
        fulfillAddressMock = fulfillAddress;
        fulfillFunctionIdMock = fulfillFunctionId;
        return requestIdMock;
    }

    address public fulfillAddressMock;
    bytes4 public fulfillFunctionIdMock;
    bytes32 public requestIdMock = keccak256(abi.encode(0x1));

    function fulfill(
        bytes32 requestId,
        address airnode,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata data,
        bytes calldata signature
    ) external returns (bool callSuccess, bytes memory callData) {
        (callSuccess, callData) = fulfillAddressMock.call( // solhint-disable-line avoid-low-level-calls
            abi.encodeWithSelector(fulfillFunctionIdMock, requestIdMock, data)
        );
        emit fullfillMock(callSuccess, callData);
    }

    function fail(
        bytes32 requestId,
        address airnode,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        string calldata errorMessage
    ) external {

    }

    function sponsorToRequesterToSponsorshipStatus(
        address sponsor,
        address requester
    ) external view returns (bool sponsorshipStatus) {

    }

    function requesterToRequestCountPlusOne(address requester)
        external
        view
        returns (uint256 requestCountPlusOne) {

        }

    function requestIsAwaitingFulfillment(bytes32 requestId)
        external
        view
        returns (bool isAwaitingFulfillment) {

        }

    function requestWithdrawal(address airnode, address sponsorWallet) external {}

    function fulfillWithdrawal(
        bytes32 withdrawalRequestId,
        address airnode,
        address sponsor
    ) external payable {}

    function sponsorToWithdrawalRequestCount(address sponsor)
        external
        view
        returns (uint256 withdrawalRequestCount) {}
}