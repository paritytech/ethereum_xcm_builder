// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/XCMBuilder.sol";
import "../src/CompactTypes.sol";

contract XCMBuilderTest is Test {
    XCMBuilder public builder;

    function setUp() public {
        builder = new XCMBuilder();
    }

    function testDecodeZero() public {
        uint256 testValue = 0;
        uint256 decodedValue = CompactTypes.decodeCompactUint("\x00");
        assertEq(testValue, decodedValue);
    }

    function testDecodeSingleByte() public {
        uint256 testValue = 1;
        uint256 decodedValue = CompactTypes.decodeCompactUint("\x04");
        assertEq(testValue, decodedValue);
    }

    function testDecodeAnotherSingleByte() public {
        uint256 testValue = 42;
        uint256 decodedValue = CompactTypes.decodeCompactUint("\xa8");
        assertEq(testValue, decodedValue);
    }

    function testDecodeTwoBytes() public {
        uint256 testValue = 69;
        uint256 decodedValue = CompactTypes.decodeCompactUint("\x15\x01");
        assertEq(testValue, decodedValue);
    }

    function testDecodeFourBytes() public {
        uint256 testValue = 65535;
        uint256 decodedValue = CompactTypes.decodeCompactUint("\xfe\xff\x03\x00");
        assertEq(testValue, decodedValue);
    }

    function testDecodeBigInt() public {
        uint256 testValue = 100000000000000;
        uint256 decodedValue = CompactTypes.decodeCompactUint("\x0b\x00\x40\x7a\x10\xf3\x5a");
        assertEq(testValue, decodedValue);
    }

    function testEncodeZero() public {
        bytes memory testValue = "\x00";
        bytes memory encodedValue = CompactTypes.encodeCompactUint(0);
        assertEq(testValue, encodedValue);
    }

    function testEncodeSingleByte() public {
        bytes memory testValue = "\x04";
        bytes memory encodedValue = CompactTypes.encodeCompactUint(1);
        assertEq(testValue, encodedValue);
    }

    function testEncodeAnotherSingleByte() public {
        bytes memory testValue = "\xa8";
        bytes memory encodedValue = CompactTypes.encodeCompactUint(42);
        assertEq(testValue, encodedValue);
    }

    function testEncodeTwoBytes() public {
        bytes memory testValue = "\x15\x01";
        bytes memory encodedValue = CompactTypes.encodeCompactUint(69);
        assertEq(testValue, encodedValue);
    }

    function testEncodeFourBytes() public {
        bytes memory testValue = "\xfe\xff\x03\x00";
        bytes memory encodedValue = CompactTypes.encodeCompactUint(65535);
        assertEq(testValue, encodedValue);
    }

    function testEncodeBigInt() public {
        bytes memory testValue = "\x0b\x00\x40\x7a\x10\xf3\x5a";
        bytes memory encodedValue = CompactTypes.encodeCompactUint(100000000000000);
        // TODO
        assertEq(testValue, encodedValue);
    }

    function testGetLengthBytes() public {
        uint256 value = 100000000000000;
        uint8 calc_length = CompactTypes.getLengthBytes(value);
        uint8 length = 6;
        assertEq(length, calc_length);
    }

    function testEncodeTransactMessage() public {
        CallEncoder.OriginKind originKind = CallEncoder.OriginKind.SovereignAccount;
        uint64 requiredWeightAtMost = 10000000000;
        bytes memory transactBytes = "\x00\x08\x04\x01";
        bytes memory testMessage = "\x06\x01\x07\x00\xe4\x0b\x54\x02\x10\x00\x08\x04\x01";
        bytes memory encodedMessage = builder.encodeTransactMessage(
            originKind, 
            requiredWeightAtMost, 
            transactBytes
        );
        assertEq(encodedMessage, testMessage);
    }

    function testEncodeMessage() public {
        uint8 numMessages = 3;
        bytes memory messagesBytes = "\x24\x09\x05\x0b\x02\x00\xa1\x0f\x01\x01\x03\x1c\xbd\x2d\x43\x53\x0a\x44\x70\x5a\xd0\x88\xaf\x31\x3e\x18\xf8\x0b\x53\xef\x16\xb3\x61\x77\xcd\x4b\x77\xb8\x46\xf2\xa5\xf0\x7c\x06\x01\x07\x00\xe4\x0b\x54\x02\x10\x00\x08\x04\x01";
        uint256 parachainId = 1000;
        bytes memory testMessage = "\x01\x02\x09\x06\x00\xa1\x0f\x03\x0c\x24\x09\x05\x0b\x02\x00\xa1\x0f\x01\x01\x03\x1c\xbd\x2d\x43\x53\x0a\x44\x70\x5a\xd0\x88\xaf\x31\x3e\x18\xf8\x0b\x53\xef\x16\xb3\x61\x77\xcd\x4b\x77\xb8\x46\xf2\xa5\xf0\x7c\x06\x01\x07\x00\xe4\x0b\x54\x02\x10\x00\x08\x04\x01";
        bytes memory encodedMessage = builder.createXcm(
            numMessages, 
            messagesBytes, 
            parachainId
        );
        assertEq(encodedMessage, testMessage);
    }
}
