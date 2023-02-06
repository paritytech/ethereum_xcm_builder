// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library CallEncoder {
    
    // Currently using a limited number of instructions used with BridgeHub
    enum XcmV3Instruction {
        ExportMessage,
        DescendOrigin,
        UniversalOrigin,
        Transact,
        Trap
    }

    enum XcmV3Junction {
        Parachain, 
        AccountId32,
        AccountIndex64, 
        AccountKey20,
        PalletInstance, 
        GeneralIndex,
        GeneralKey,
        OnlyChild, 
        Plurality,
        GlobalConsensus
    }

    // Currently using only up to X2 level Junctions
    enum XcmV3Junctions {
        Here, 
        X1, 
        X2
    }

    enum XcmV3JunctionNetworkId {
        ByGenesis,
        ByFork,
        Polkadot, 
        Kusama, 
        Westend, 
        Rococo,
        Wococo,
        EthereumFoundation, 
        EthereumClassic,
        BitcoinCore, 
        BitcoinCash
    }

    enum OriginKind {
        Native, 
        SovereignAccount,
        Superuser,
        Xcm
    }

    function encodeCallIndex() internal pure returns (bytes memory) {
        return hex"1f00";
    }
}