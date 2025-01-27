#
# `$ just`
#
# Just is a command runner.
# You can download it from https://github.com/casey/just
# Alternatively, you can just read the file and run the commands manually.
#

# By default just list all available commands
[private]
default:
    @just -l

# Fails if sui is not a binary
[private]
_check_sui:
    #!/bin/bash
    if ! command -v sui 2>&1 >/dev/null
    then
        echo "sui binary not found"
        echo "You can download the binary from https://github.com/MystenLabs/sui/releases"
        exit 1
    fi

# Builds all things Sui
build: _check_sui
    sui move build -p steamm

# Tests all things Sui
test: _check_sui
    sui move test -p steamm --gas-limit 5000000000000

# Starts a localnet faucet process on port 9123 that airdrops 500 SUI
faucet: _check_sui
    ../sui/sui-faucet --write-ahead-log $HOME/.sui/sui_config/faucet.wal --port 9123 --amount 500000000000

# Starts the localnet network
local: _check_sui
    sui start

# Fails if sui is not a binary
[private]
_check_sui:
    #!/bin/bash
    if ! command -v sui 2>&1 >/dev/null
    then
        echo "sui binary not found"
        echo "You can download the binary from https://github.com/MystenLabs/sui/releases"
        exit 1
    fi


# Regenerates the smart contract bindings
bind:
    rm -rf sdk/src/_codegen/_generated/_dependencies/*
    rm -rf sdk/src/_codegen/_generated/_framework/*
    rm -rf sdk/src/_codegen/_generated/slamm/*
    rm -rf sdk/src/_codegen/_generated/.eslintrc.json

    sui-client-gen --manifest sdk/src/_codegen/_generated --out sdk/src/_codegen/_generated

# Publishes packages to localnet and runs ts tests
setup:
    bash -c './bin/publocal.sh'
unset:
    bash -c './bin/unpublocal.sh'

test:
    bash -c './bin/publocal.sh'
    bun test ./sdk/tests/index.test.ts
    bash -c './bin/unpublocal.sh'

