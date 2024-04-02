set -o errexit
set -o pipefail
set -o nounset
set -o functrace
set -o errtrace
set -o monitor
set -o posix
shopt -s dotglob

cardano-cli conway query gov-state | jq -r '.proposals' > gov-actions.json
echo "Updated gov-actions.json"
