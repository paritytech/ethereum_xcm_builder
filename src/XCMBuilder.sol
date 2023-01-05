// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./CallEncoder.sol";
import "./ScaleCodec.sol";
import "./CompactTypes.sol";


contract XCMBuilder {

    mapping(CallEncoder.Instruction => bytes1) public InstructionEncoded;

    bytes public messageVersion = bytes.concat(hex"03", hex"04");

    constructor () {

        CallEncoder.Instruction instructionTransact = CallEncoder.Instruction.Transact;
        CallEncoder.Instruction instructionTrap = CallEncoder.Instruction.Trap;
        CallEncoder.Instruction instructionExportMessage = CallEncoder.Instruction.ExportMessage;

        // the indices of instructions in the PolkadotXcm pallet of BridgeHub's runtime
        uint8 instructionIndexTransact = 6;
        uint8 instructionIndexTrap = 25;
        uint8 instructionIndexExportMessage = 37;
        
        InstructionEncoded[instructionTrap] = ScaleCodec.encodeU8(instructionIndexTrap);
        InstructionEncoded[instructionTransact] = ScaleCodec.encodeU8(instructionIndexTransact);
        InstructionEncoded[instructionExportMessage] = ScaleCodec.encodeU8(instructionIndexExportMessage);
    }

    function encodeMessage(CallEncoder.Instruction instruction, uint256 value) internal view returns (bytes memory) {
        return bytes.concat(abi.encodePacked(InstructionEncoded[instruction]), CompactTypes.encodeCompactUint(value));
    }

    function encodeDestination(uint8 xcmVersion, uint8 parents, CallEncoder.Junctions interiorJunctions) public pure returns (bytes memory) {
        return abi.encodePacked(
            // 0 for V2, 1 for V3
            ScaleCodec.encodeU8(uint8(xcmVersion)), 
            ScaleCodec.encodeU8(uint8(parents)),
            // 0 for Here, 1 for X1, 2 for X2
            ScaleCodec.encodeU8(uint8(interiorJunctions))
        );
    }

    function createXcm(
        CallEncoder.Instruction instruction,
        uint8 xcmVersion,
        uint8 parents,
        CallEncoder.Junctions interiorJunctions,
        uint256 value) 
    public view returns (bytes memory) {
        bytes memory callIndexEncoded = CallEncoder.encodeCallIndex();
        bytes memory messageEncoded = encodeMessage(instruction, value);
        bytes memory destination = encodeDestination(xcmVersion, parents, interiorJunctions);
        return bytes.concat(
            callIndexEncoded,
            destination,
            messageVersion,
            messageEncoded
        );
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
