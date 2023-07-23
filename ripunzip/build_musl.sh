#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

apk update
apk add --no-cache alpine-sdk curl rustup

echo "::endgroup::"

rustup-init -y

. "$HOME/.cargo/env"

rustc --version
cargo --version



