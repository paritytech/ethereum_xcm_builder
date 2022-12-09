// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/XCMBuilder.sol";

contract XCMBuilderTest is Test {
    XCMBuilder public builder;

    function setUp() public {
        builder = new XCMBuilder();
    }
}
