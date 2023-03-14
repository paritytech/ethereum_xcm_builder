// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./CallEncoder.sol";
import "./utils/ScaleCodec.sol";
import "./CompactTypes.sol";

contract XCMBuilder {
    mapping(CallEncoder.XcmV3Instruction => bytes1) public InstructionEncoded;

    bytes public messageVersion = hex"03";

    CallEncoder.XcmV3Instruction instructionTransact = CallEncoder.XcmV3Instruction.Transact;
    CallEncoder.XcmV3Instruction instructionDescendOrigin = CallEncoder.XcmV3Instruction.DescendOrigin;
    CallEncoder.XcmV3Instruction instructionTrap = CallEncoder.XcmV3Instruction.Trap;
    CallEncoder.XcmV3Instruction instructionUniversalOrigin = CallEncoder.XcmV3Instruction.UniversalOrigin;
    CallEncoder.XcmV3Instruction instructionExportMessage = CallEncoder.XcmV3Instruction.ExportMessage;

    // the indices of instructions in the PolkadotXcm pallet of BridgeHub's runtime
    // TODO: onlyOwner can update these values
    uint8 instructionIndexTransact = 6;
    uint8 instructionIndexDescendOrigin = 11;
    uint8 instructionIndexTrap = 25;
    uint8 instructionIndexUniversalOrigin = 37;
    uint8 instructionIndexExportMessage = 38;

    constructor() {
        InstructionEncoded[instructionTransact] = ScaleCodec.encodeU8(instructionIndexTransact);
        InstructionEncoded[instructionDescendOrigin] = ScaleCodec.encodeU8(instructionIndexDescendOrigin);
        InstructionEncoded[instructionTrap] = ScaleCodec.encodeU8(instructionIndexTrap);
        InstructionEncoded[instructionUniversalOrigin] = ScaleCodec.encodeU8(instructionIndexUniversalOrigin);
        InstructionEncoded[instructionExportMessage] = ScaleCodec.encodeU8(instructionIndexExportMessage);
    }

    // the global consensus parameters can be made generic for messages
    // coming from other consensus environments
    function encodeUniversalOrigin(uint256 chainId) public view returns (bytes memory) {
        // uint256 chainId = block.chainid; // Ethereum mainnet ChainID 1
        bytes memory globalConsensusEthereum = hex"0907";
        return abi.encodePacked(
            InstructionEncoded[instructionUniversalOrigin],
            globalConsensusEthereum,
            CompactTypes.encodeCompactUint(chainId)
        );
    }

    function encodeDescendOrigin(uint256 chainId) internal view returns (bytes memory) {
        CallEncoder.XcmV3Junctions interiorJunctions = CallEncoder.XcmV3Junctions.X1;
        CallEncoder.XcmV3Junction junction = CallEncoder.XcmV3Junction.AccountKey20;
        CallEncoder.XcmV3JunctionNetworkId network = CallEncoder.XcmV3JunctionNetworkId.Ethereum;
        return abi.encodePacked(
            InstructionEncoded[instructionDescendOrigin],
            ScaleCodec.encodeU8(uint8(interiorJunctions)),
            ScaleCodec.encodeU8(uint8(junction)),
            hex"01", // TODO add encoding of Option Some
            ScaleCodec.encodeU8(uint8(network)),
            CompactTypes.encodeCompactUint(chainId),
            msg.sender
        );
    }

    // Current inputs should be the following:
    // originKind: 1 (for SovereignAccount)
    // requiredWeightAtMost:
    //     refTime: 1000000000
    //     proofSize: 10
    // transactBytes: 0x00070401 (test extrinsic `system.remarkWithEvent`)
    function encodeTransactMessage(
        CallEncoder.OriginKind originKind,
        uint64 refTime,
        uint64 proofSize,
        bytes memory transactBytes
    ) public view returns (bytes memory) {
        uint256 lengthBytes = transactBytes.length;
        return abi.encodePacked(
            InstructionEncoded[instructionTransact],
            originKind,
            CompactTypes.encodeCompactUint(refTime),
            CompactTypes.encodeCompactUint(proofSize),
            CompactTypes.encodeCompactUint(lengthBytes),
            transactBytes
        );
    }

    // Current inputs should be the following:
    // parachainId: 1000
    function encodeDestination(uint256 parachainId) public pure returns (bytes memory) {
        uint8 parents = 1;
        CallEncoder.XcmV3Junctions interiorJunctions = CallEncoder.XcmV3Junctions.X2;
        CallEncoder.XcmV3Junction firstJunction = CallEncoder.XcmV3Junction.GlobalConsensus;
        CallEncoder.XcmV3JunctionNetworkId network = CallEncoder.XcmV3JunctionNetworkId.Wococo;
        CallEncoder.XcmV3Junction secondJunction = CallEncoder.XcmV3Junction.Parachain;
        return abi.encodePacked(
            ScaleCodec.encodeU8(uint8(parents)),
            ScaleCodec.encodeU8(uint8(interiorJunctions)),
            ScaleCodec.encodeU8(uint8(firstJunction)),
            ScaleCodec.encodeU8(uint8(network)),
            ScaleCodec.encodeU8(uint8(secondJunction)),
            CompactTypes.encodeCompactUint(parachainId)
        );
    }

    // Current inputs should be the following:
    // parachainId: 1000
    // originKind: 1 (SovereignAccount)
    // refTime: 1000000000
    // proofSize: 10
    // transactBytes: 0x00070401 (system.remarkWithEvent)
    function createXcm(
        uint256 chainId,
        uint256 parachainId,
        CallEncoder.OriginKind originKind,
        uint64 refTime,
        uint64 proofSize,
        bytes memory transactBytes1,
        bytes memory transactBytes2,
        bytes memory transactBytes3
    ) public view returns (bytes memory) {
        bytes memory destination = encodeDestination(parachainId);
        uint8 numMessages = 2; // UniversalOrigin, DescendOrigin
        bytes memory universalOriginMessage = encodeUniversalOrigin(chainId);
        bytes memory descendOriginMessage = encodeDescendOrigin(chainId);
        bytes memory transactMessages = "";

        if (transactBytes1.length > 0) {
            numMessages += 1;
            bytes memory transactMessage1 = encodeTransactMessage(originKind, refTime, proofSize, transactBytes1);
            transactMessages = abi.encodePacked(transactMessages, transactMessage1);
        }

        if (transactBytes2.length > 0) {
            numMessages += 1;
            bytes memory transactMessage2 = encodeTransactMessage(originKind, refTime, proofSize, transactBytes2);
            transactMessages = abi.encodePacked(transactMessages, transactMessage2);
        }

        if (transactBytes3.length > 0) {
            numMessages += 1;
            bytes memory transactMessage3 = encodeTransactMessage(originKind, refTime, proofSize, transactBytes3);
            transactMessages = abi.encodePacked(transactMessages, transactMessage3);
        }

        return abi.encodePacked(
            destination,
            messageVersion,
            CompactTypes.encodeCompactUint(numMessages),
            universalOriginMessage,
            descendOriginMessage,
            transactMessages
        );
    }

    // Does not modify the input
    function genericXcm(bytes memory message) public pure returns (bytes memory) {
        return abi.encodePacked(message);
    }

    // To be removed
    function decodeValue(bytes memory value) public pure returns (uint256) {
        return CompactTypes.decodeCompactUint(value);
    }

    // To be removed
    function encodeValue(uint256 value) public pure returns (bytes memory) {
        return CompactTypes.encodeCompactUint(value);
    }
}
