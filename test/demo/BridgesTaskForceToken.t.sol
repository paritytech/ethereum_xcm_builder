pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/demo/BridgesTaskForceToken.sol";

contract BridgesTaskForceTokenTest is Test {
    BridgesTaskForceToken token;

    function setUp() public {
        token = new BridgesTaskForceToken();
    }

    function testTokenConstructor() external {
        assertEq("BridgesTaskForceToken", token.name());
        assertEq("BTFT", token.symbol());
        assertEq(5 * (10 ** 18), token.totalSupply());
    }
}
