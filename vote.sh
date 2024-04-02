set -o errexit
set -o pipefail
set -o nounset
set -o functrace
set -o errtrace
set -o monitor
set -o posix
shopt -s dotglob

source ./check-env.sh

USAGE="usage: ./vote.sh <action-tx-id> <action-ix> <anchor-ipfs-cid> <canonized-file> (yes|no|abstain)"

# Read the tx ID of the governance action from argument 1
ACTION_TX_ID="${1:-}"
[ -z "$ACTION_TX_ID" ] && echo "$USAGE" && exit 1

# Read the index of the governance action from argument 2
ACTION_IX="${2:-}"
[ -z "$ACTION_IX" ] && echo "$USAGE" && exit 1

# Read the anchor URL from argument 3
ANCHOR_URL="${3:-}"
[ -z "$ANCHOR_URL" ] && echo "$USAGE" && exit 1

# Read the anchor hash from argument 4
ANCHOR_FILE="${4:-}"
[ -z "$ANCHOR_FILE" ] && echo "$USAGE" && exit 1

# Read the choice from argument 5
CHOICE="${5:-}"
[ -z "$CHOICE" ] && echo "$USAGE" && exit 1

VOTE_FILE="$(mktemp -t vote.XXXXXX)"

echo "Generating vote file: $VOTE_FILE"

# Hash the anchor file
ANCHOR_HASH=$(cardano-cli conway governance hash anchor-data --file-text "$ANCHOR_FILE" --out-file /dev/stdout)

# Generates a vote file.
cardano-cli conway governance vote create \
  --"$CHOICE" \
  --governance-action-tx-id "$ACTION_TX_ID" \
  --governance-action-index "$ACTION_IX" \
  --cc-hot-verification-key-file "$HOT_VKEY" \
  --anchor-url "$ANCHOR_URL" \
  --anchor-data-hash "$ANCHOR_HASH" \
  --out-file "$VOTE_FILE"

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
  --vote-file "$VOTE_FILE" \
  --out-file "$TX_BODY_FILE"

TX_ID="$(cardano-cli conway transaction txid --tx-body-file "$TX_BODY_FILE")"

echo "TxId: $TX_ID"

# Hot key must sign the transaction to publish vote.
# Payment key must sign the transaction to spend the transaction input.
cardano-cli conway transaction sign \
  --tx-body-file "$TX_BODY_FILE" \
  --signing-key-file "$HOT_SKEY" \
  --signing-key-file "$PAYMENT_SKEY" \
  --out-file "$TX_FILE"

# Submit transaction to node.
cardano-cli conway transaction submit --tx-file "$TX_FILE"
