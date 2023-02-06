// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./CallEncoder.sol";
import "./utils/ScaleCodec.sol";
import "./CompactTypes.sol";


contract XCMBuilder {

    mapping(CallEncoder.XcmV3Instruction => bytes1) public InstructionEncoded;

    bytes public messageVersion = hex"03";

    constructor () {

        CallEncoder.XcmV3Instruction instructionTransact = CallEncoder.XcmV3Instruction.Transact;
        CallEncoder.XcmV3Instruction instructionDescendOrigin = CallEncoder.XcmV3Instruction.DescendOrigin;
        CallEncoder.XcmV3Instruction instructionTrap = CallEncoder.XcmV3Instruction.Trap;
        CallEncoder.XcmV3Instruction instructionUniversalOrigin = CallEncoder.XcmV3Instruction.UniversalOrigin;
        CallEncoder.XcmV3Instruction instructionExportMessage = CallEncoder.XcmV3Instruction.ExportMessage;

        // the indices of instructions in the PolkadotXcm pallet of BridgeHub's runtime
        uint8 instructionIndexTransact = 6;
        uint8 instructionIndexDescendOrigin = 11;
        uint8 instructionIndexTrap = 23;
        uint8 instructionIndexUniversalOrigin = 34;
        uint8 instructionIndexExportMessage = 35;

        InstructionEncoded[instructionTransact] = ScaleCodec.encodeU8(instructionIndexTransact);
        InstructionEncoded[instructionDescendOrigin] = ScaleCodec.encodeU8(instructionIndexDescendOrigin);
        InstructionEncoded[instructionTrap] = ScaleCodec.encodeU8(instructionIndexTrap);
        InstructionEncoded[instructionUniversalOrigin] = ScaleCodec.encodeU8(instructionIndexUniversalOrigin);
        InstructionEncoded[instructionExportMessage] = ScaleCodec.encodeU8(instructionIndexExportMessage);
    }

    // Current inputs should be the following: 
    // originKind: 1
    // requiredWeightAtMost: 10000000000
    // transactBytes: 0x00080401
    function encodeTransactMessage(
        CallEncoder.OriginKind originKind,
        uint64 requiredWeightAtMost,
        bytes memory transactBytes 
    ) 
    public view returns (bytes memory) {
        uint256 lengthBytes = transactBytes.length;
        return bytes.concat(
            abi.encodePacked(
                InstructionEncoded[CallEncoder.XcmV3Instruction.Transact],
                originKind
            ), 
            CompactTypes.encodeCompactUint(requiredWeightAtMost),
            CompactTypes.encodeCompactUint(lengthBytes),
            transactBytes
        );
    }
    
    // Current inputs should be the following: 
    // parachainId: 1000
    function encodeDestination(
        uint256 parachainId 
    )
    public pure returns (bytes memory) {
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
    // numMessages: 3
    // messagesBytes: 0x2409050b0200a10f0101031cbd2d43530a44705ad088af313e18f80b53ef16b36177cd4b77b846f2a5f07c06010700e40b54021000080401
    // parachainId: 1000
    function createXcm(
        uint8 numMessages,
        bytes memory messagesBytes,
        uint256 parachainId 
    ) 
    public view returns (bytes memory) {
        bytes memory destination = encodeDestination(parachainId);
        return bytes.concat(
            destination,
            messageVersion,
            CompactTypes.encodeCompactUint(numMessages),
            messagesBytes
        );
    }

    // Does not modify the input 
    function genericXcm(bytes memory message) public pure returns (bytes memory) {
        return abi.encodePacked(message);
    }

    // To be removed 
    function decodeValue(bytes memory value) pure public returns (uint256) {
        return CompactTypes.decodeCompactUint(value);
    }

    // To be removed 
    function encodeValue(uint256 value) pure public returns (bytes memory) {
        return CompactTypes.encodeCompactUint(value);
    }
}
