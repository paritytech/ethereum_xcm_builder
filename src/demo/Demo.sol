pragma solidity ^0.8.13;

import "../XCMBuilder.sol";
import "../CallEncoder.sol";

contract Demo {
    // constant values
    uint256 public constant WESTMINT_PARACHAIN_ID = 1000;
    uint64 public constant REF_TIME = 1000000000;
    uint64 public constant PROOF_SIZE = 10;
    CallEncoder.OriginKind public constant ORIGIN_KIND = CallEncoder.OriginKind.SovereignAccount;

    mapping(bytes32 => bytes) bridgedMessages;

    XCMBuilder public builder;

    // events
    event BridgeMessageCreated(bytes32 messageId, bytes encodedMessage);

    // functions
    constructor() {
        builder = new XCMBuilder();
    }

    function encodeTransactMessage(bytes memory encodedCall1, bytes memory encodedCall2, bytes memory encodedCall3)
        public
    {
        bytes memory encodedMessage = builder.createXcm(
            block.chainid,
            WESTMINT_PARACHAIN_ID,
            ORIGIN_KIND,
            REF_TIME,
            PROOF_SIZE,
            encodedCall1,
            encodedCall2,
            encodedCall3
        );

        bytes32 messageId = keccak256(abi.encodePacked(block.timestamp, msg.sender, encodedMessage));
        bridgedMessages[messageId] = encodedMessage;

        emit BridgeMessageCreated(messageId, encodedMessage);
    }

    function getMessage(bytes32 messageId) public view returns (bytes memory) {
        return bridgedMessages[messageId];
    }
}
