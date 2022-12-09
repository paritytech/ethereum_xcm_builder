NODE_RPC_URL="http://127.0.0.1:8545"
DEPLOYER="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
CONTRACT="XCMBuilder"

forge create --rpc-url ${NODE_RPC_URL} --private-key "${DEPLOYER}" "src/${CONTRACT}.sol:${CONTRACT}"
