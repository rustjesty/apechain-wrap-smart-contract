source .env
forge create --rpc-url $APECHAIN_RPC_URL --private-key $PRIVATE_KEY src/WnAPE.sol:WnAPE --verify --verifier sourcify --etherscan-api-key $APESCAN_API_KEY --broadcast -vvvv --value 1000000000000000000
forge create --rpc-url $MAINNET_RPC_URL --private-key $PRIVATE_KEY src/lz/WnAPEOFT.sol:WnAPEOFT --verify --verifier sourcify --etherscan-api-key $ETHERSCAN_API_KEY --broadcast -vvvv --constructor-args $LZ_ENDPOINT_MAINNET $DELEGATE_ADDRESS
forge create --rpc-url $APECHAIN_RPC_URL --private-key $PRIVATE_KEY src/lz/WnAPEOFTAdapter.sol:WnAPEOFTAdapter --verify --verifier sourcify --etherscan-api-key $APESCAN_API_KEY --broadcast -vvvv --constructor-args $WNAPE_ADDRESS $LZ_ENDPOINT_APECHAIN $DELEGATE_ADDRESS
