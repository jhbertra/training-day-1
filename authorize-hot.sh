set -o errexit
set -o pipefail
set -o nounset
set -o functrace
set -o errtrace
set -o monitor
set -o posix
shopt -s dotglob

source ./check-env.sh

CERT_FILE="$(mktemp -t authorize-host.XXXXXX.cert)"

echo "Generating CC member hot key authorization certificate: $CERT_FILE"

# Generates an authorization certificat file for the hot key.
cardano-cli conway governance committee create-hot-key-authorization-certificate \
  --cold-verification-key-file "$COLD_VKEY" \
  --hot-key-file "$HOT_VKEY" \
  --out-file "$CERT_FILE"

# Find a UTxO with more than enough ADA to cover the tx fee
TX_IN="$(cardano-cli query utxo --address "$PAYMENT_ADDRESS" --out-file /dev/stdout | jq -r 'select(.[].value.lovelace > 2000000) | keys[0]')"

[ -z "$TX_IN" ] && echo "No UTxOs found at payment address." && exit 1

echo "Paying for transaction fees with : $TX_IN"

# Generate temp files for the tx body and tx.
TX_BODY_FILE="$(mktemp -t XXXXXX.txbody)"
TX_FILE="$(mktemp -t XXXXXX.tx)"

echo "Tx body will be written to: $TX_BODY_FILE"
echo "Signed tx will be written to: $TX_FILE"

# Build the transaction that publishes the certificate
cardano-cli conway transaction build \
  --witness-override 2 \
  --tx-in "$TX_IN" \
  --change-address "$PAYMENT_ADDRESS" \
  --certificate-file "$CERT_FILE" \
  --out-file "$TX_BODY_FILE"

TX_ID="$(cardano-cli conway transaction txid --tx-body-file "$TX_BODY_FILE")"

echo "TxId: $TX_ID"

# Cold key must sign the transaction to publish authorization certificate.
# Payment key must sign the transaction to spend the transaction input.
cardano-cli conway transaction sign \
  --tx-body-file "$TX_BODY_FILE" \
  --signing-key-file "$COLD_SKEY" \
  --signing-key-file "$PAYMENT_SKEY" \
  --out-file "$TX_FILE"

# Submit transaction to node.
cardano-cli conway transaction submit --tx-file "$TX_FILE"
