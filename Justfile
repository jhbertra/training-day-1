set shell := ["nu", "-c"]
set positional-arguments

export UNSTABLE := "true"
export UNSTABLE_LIB := "true"
export DEBUG := "true"

default:
  @just --list

lint:
  deadnix -f
  statix check

show-flake:
  nix flake show --allow-import-from-derivation

start-node:
  #!/usr/bin/env bash
  DATA_DIR=~/.local/share/cardano ENVIRONMENT=private SOCKET_PATH="./cc-public/node.socket" nohup nix run .#run-cardano-node & echo $! > cc-public/cardano.pid &

stop-node:
  #!/usr/bin/env bash
  if [ -f cc-public/cardano.pid ]; then
    kill $(< cc-public/cardano.pid)
    rm cc-public/cardano.pid
  fi
