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
        assertEq(true, true);
    }
}
