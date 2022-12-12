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

## Build the project
```sh
forge build
```

## Format code
```sh
forge fmt
```

## Run tests
```sh
forge test
```

## Deploy locally

### Run local node
At first, run a single local node with *anvil* using a script:
```sh
./node.sh
```

### Deploy smart contract
To deploy smart contracts, use dedicated shell script:
```sh
./deploy.sh
```
