set -o errexit
set -o pipefail
set -o nounset
set -o functrace
set -o errtrace
set -o monitor
set -o posix
shopt -s dotglob

source ./check-env.sh

cardano-cli conway query committee-state --cold-verification-key-file "$COLD_VKEY"
