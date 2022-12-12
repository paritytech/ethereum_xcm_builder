MNEMONIC="test test test test test test test test test test test junk"
DERIVATION_PATH="m/44'/60'/0'/0/"
PORT=8545
ACCOUNTS_NO=10

anvil --mnemonic "${MNEMONIC}" --derivation-path "${DERIVATION_PATH}" --port ${PORT} --accounts ${ACCOUNTS_NO}
