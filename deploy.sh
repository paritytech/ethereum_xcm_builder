 # exit when any command fails
set -e

NODE_RPC_URL="http://127.0.0.1:8545"
DEPLOYER="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
BYTES="Bytes"
MEMORY="Memory"
SCALECODEC="ScaleCodec"
COMPACTTYPES="CompactTypes"
CALLENCODER="CallEncoder"
XCMBUILDER="XCMBuilder"



deploy () {
    contract=$1
    echo "------------------------------------------------------------------------------------"
    echo "Deploying contract: ${contract} ..."
    forge create --rpc-url ${NODE_RPC_URL} --private-key "${DEPLOYER}" "${contract}"    
    echo "Contract: ${contract} deployed successfully!"
    echo "------------------------------------------------------------------------------------\n"
}

deploy "src/utils/${MEMORY}.sol:${MEMORY}"
deploy "src/utils/${BYTES}.sol:${BYTES}"
deploy "src/utils/${SCALECODEC}.sol:${SCALECODEC}"
deploy "src/${COMPACTTYPES}.sol:${COMPACTTYPES}"
deploy "src/${CALLENCODER}.sol:${CALLENCODER}"
deploy "src/${XCMBUILDER}.sol:${XCMBUILDER}"
