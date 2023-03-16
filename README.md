# Ethereum XCM Message Builder
This repository contains *Ethereum* smart contracts for [Snowbridge](https://github.com/Snowfork/snowbridge) that creates *XCMv3* messages to be sent via *BridgeHub* to *Polkadot*.

## Setup

### Foundry
**Foundry** is a blazing fast, portable and modular toolkit for *Ethereum* application development written in Rust.

**Foundry** consists of:
- *Forge*: *Ethereum* testing framework;
- *Cast*: Swiss army knife for interacting with *EVM* smart contracts, sending transactions and getting chain data;
- *Anvil*: local Ethereum node;

To install **Foundry**, follow the instructions from the [webpage](https://getfoundry.sh/).

### Dependencies
```sh
git submodule update --init --recursive
forge install
```

### Build the project
```sh
forge build
```

### Format code
```sh
forge fmt
```

### Run tests
```sh
forge test
```

## Deploy locally

### Run local node
At first, run a single local node with *anvil* using a script:
```sh
./node.sh
```

### Deploy smart contracts
To deploy the set of smart contracts, use dedicated shell script:
```sh
./deploy.sh
```

## Spinning up the infrastructure 

It is possible to test messages in the directions:

`Kusama <-> Polkadot`
`Ethereum -> Polkadot`

with the infrastructure described in the [bridge-infra repository](https://github.com/paritytech/bridge-infra).


## Creating an XCM message that is executed at the BridgeHub

### Make a cast call to XCMBuilder.sol 

The input parameters to `createXcm`:
```
uint256 parachainId = 1000
uint64 refTime = 1000000000
uint64 proofSize= 10
bytes memory transactBytes = 0x00070401
```

The parachain ID belongs to Westmint, and the bytes stand for `system.remarkWithEvent` on Westmint.

```sh
cast call --private-key YOUR_PRIVATE_KEY \
--rpc-url http://localhost:8545 \
YOUR_CONTRACT_ADDRESS \
"createXcm(uin256, uint8, uint64, uint64, bytes)" 1000 1 1000000000 10 0x00070401 
```

TODO: why exactly does `cast` pad the result with zeros? 

The output should be 
`0x0102090600a10f030c250907140b0103010714f39fd6e51aad88f6f4ce6ab8827279cfffb92266060102286bee281000070401`

Message dissected:

```
0x
01 (parents Here `u8`)
02 (X2 `XcmV3Junctions`)
09 (GlobalConsensus `XcmV3Junction`)
06 (Wococo `XcmV3JunctionNetworkId`)
00 (Parachain `XcmV3Junction`)
a10f (1000 `Compact<u32>`)
03 (message `XcmVersionedXcm`)
0c (number of messages `Compact<u64>`)
25 (UniversalOrigin index 37 `XcmV3Instruction`)
09 (GlobalConsensus `XcmV3Junction`)
07 (Ethereum `XcmV3JunctionNetworkId`)
14 (chainId 5 `Compact<u64>`)
0b (DescendOrigin index 11 `XcmV3Instruction`)
01 (X1 `XcmV3Junctions`)
03 (AccountId20 `XcmV3Junction`)
01 (Some)
07 (Ethereum `XcmV3JunctionNetworkId`)
14 (chainId 5 `Compact<u64>`)
f39fd6e51aad88f6f4ce6ab8827279cfffb92266 (id `[u8;20]`) (address is specific to local Anvil node)
06 (Transact index 6 `XcmV3Instruction`)
01 (SovereignAccount `OriginKind`)
02286bee (refsize 1000000000 `Compact<u64>`)
28 (proofsize 10 `Compact<u64>`)
10 (length of following bytes 4 `Compact<u64>`)
00070401 (bytes on Westmint for `system.remarkWithEvent` call)
```

## Testing the XCM with the bridge infra

This ouput can be pasted into `bridgeWococoMessages` pallet's extrinsic `executeEncodedMessage`. The bytes inside `Transact` will be executed on the parachain with ID 1000 (in our case, Westmint). The event will be emitted and visible in the explorer. 

### Testing balance transfers with bridge infra 


### Prefund Alice's proxy account 

Alice's proxy account is her hashed MultiLocation on Ethereum. A quick way to get her account:

Call on BridgeHub:
`0x0102090600a10f030c250907140b0103010714f39fd6e51aad88f6f4ce6ab8827279cfffb92266060102286bee2818450201000000` `(playground.doSomethingAsSigned(1))`

Find Alice's proxy address on Westmint in `playground.TriggeredSigned` event:
5GZuzM4A64eonSJ1EWaQRDehJreCfXGSiMo3gZ3sdMoxwhcQ

This account needs to prefunded before Alice can transfer balances.

`balances.transfer(dest, amount)` with parameters Alice and 0.5
length of message: `a4` (18 bytes)
`a40a0000d43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d070088526a74`

Message that Alice can send from BridgeHub to successfuly move funds from her proxy address:

`0x0102090600a10f030c250907140b0103010714f39fd6e51aad88f6f4ce6ab8827279cfffb92266060102286bee28a40a0000d43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d070088526a74`