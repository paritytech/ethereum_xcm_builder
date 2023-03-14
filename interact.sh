set -e

NODE_RPC_URL="http://127.0.0.1:8545"
DEPLOYER_ACCOUNT="0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
DEPLOYER_PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
TOKEN_CONTRACT="0x5FbDB2315678afecb367f032d93F642f64180aa3"
DEMO_CONTRACT="0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512"

call_data_1=$1
call_data_2=$2
call_data_3=$3
cast send "${DEMO_CONTRACT}"  "encodeTransactMessage(bytes memory, bytes memory, bytes memory)"  "${call_data_1}" "${call_data_2}" "${call_data_3}" --rpc-url ${NODE_RPC_URL} --private-key "${DEPLOYER_PRIVATE_KEY}"
