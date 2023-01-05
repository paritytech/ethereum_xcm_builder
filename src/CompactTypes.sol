// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "./ScaleCodec.sol";

library CompactTypes {

    function decodeCompactUint(bytes memory value) internal pure returns (uint256) {
        
        uint8 byte1 = uint8(value[0]);
        // mask (0b11 = 3) to get the last two bits of the first byte
        uint8 mode = byte1 & 3; 

        if (mode == 0) {
        
            // remove mode flag
            return byte1 >> 2; 
        
        } else if (mode == 1) {
            
            uint8 byte2 = uint8(value[1]);
            // reverse little endian order, remove mode flag
            return (byte1 | (uint32(byte2) << 8)) >> 2;
        
        } else if (mode == 2) {
        
            uint8 byte2 = uint8(value[1]);
            uint8 byte3 = uint8(value[2]);
            uint8 byte4 = uint8(value[3]);
        
            // reverse little endian order, remove mode flag
            return (byte1 | (uint64(byte2) << 8) | (uint64(byte3) << 16) | (uint64(byte4) << 24)) >> 2;
        
        } else if (mode == 3) {
        
            uint8 numBytes = (byte1 >> 2) + 4;
            uint64 temp = 0;
            for (uint8 i = 1; i <= numBytes; i++) {
                temp = (temp | (uint64(uint8(value[i])) << (i - 1) * 8) );
            }
            return temp;
        
        } else {

            revert("Mode error");

        }

    }

    function encodeCompactUint(uint256 value) internal pure returns (bytes memory) {
        
        if (value <= 2**6 - 1) {
            
            // add single byte flag 
            return abi.encodePacked(uint8(value << 2)); 
        
        } else if (value <= 2**14 - 1) {
        
            // add two byte flag and create little endian encoding
            return abi.encodePacked(ScaleCodec.reverse16(uint16(((value << 2) + 1))));
        
        } else if (value <= 2**30 - 1) {
        
            // add four byte flag and create little endian encoding
            return abi.encodePacked(ScaleCodec.reverse32(uint32((value << 2)) + 2)); 
        
        } else {
        
            // TODO
            return abi.encodePacked(uint8(value << 2));
        
        }
    }
}