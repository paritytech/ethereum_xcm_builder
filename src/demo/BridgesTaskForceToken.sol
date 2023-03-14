pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract BridgesTaskForceToken is ERC20 {
    constructor() ERC20("BridgesTaskForceToken", "BTFT") {
        uint256 initialDeployerBalance = 5 * (10 ** 18);
        _mint(msg.sender, initialDeployerBalance);
    }
}
