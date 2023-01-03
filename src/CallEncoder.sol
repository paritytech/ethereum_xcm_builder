// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library CallEncoder {
    
    enum Instruction {
        ExportMessage,
        Transact,
        Trap
    }

    enum Junction {
        Parachain, 
        AccountId32
    }

    enum Junctions {
        Here, 
        X1, 
        X2
    }

    function encodeCallIndex() internal pure returns (bytes memory) {
        return hex"1f00";
    }
}