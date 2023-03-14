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
        uint64 refTime = 1000000000;
        uint64 proofSize = 10;
        bytes memory transactBytes = "\x00\x07\x04\x01";
        bytes memory testMessage = "\x06\x01\x02\x28\x6b\xee\x28\x10\x00\x07\x04\x01";
        bytes memory encodedMessage = builder.encodeTransactMessage(originKind, refTime, proofSize, transactBytes);
        assertEq(encodedMessage, testMessage);
    }

    // TODO: change test to new message batch
    function testEncodeMessage() public {
        address addr = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        vm.prank(addr);
        CallEncoder.OriginKind originKind = CallEncoder.OriginKind.SovereignAccount;
        uint64 refTime = 1000000000;
        uint64 proofSize = 10;
        bytes memory transactBytes1 = "\x45\x02\x02\x00\x00\x00";
        bytes memory transactBytes2 = "\x45\x02\x02\x00\x00\x00";
        bytes memory transactBytes3 = "\x45\x02\x02\x00\x00\x00";
        uint256 parachainId = 1000;
        bytes memory testMessage =
            "\x01\x02\x09\x06\x00\xa1\x0f\x03\x14\x25\x09\x07\x14\x0b\x01\x03\x01\x07\x14\xf3\x9f\xd6\xe5\x1a\xad\x88\xf6\xf4\xce\x6a\xb8\x82\x72\x79\xcf\xff\xb9\x22\x66\x06\x01\x02\x28\x6b\xee\x28\x18\x45\x02\x02\x00\x00\x00\x06\x01\x02\x28\x6b\xee\x28\x18\x45\x02\x02\x00\x00\x00\x06\x01\x02\x28\x6b\xee\x28\x18\x45\x02\x02\x00\x00\x00";
        bytes memory encodedMessage = builder.createXcm(
            parachainId, originKind, refTime, proofSize, transactBytes1, transactBytes2, transactBytes3
        );
        assertEq(encodedMessage, testMessage);
    }
}
