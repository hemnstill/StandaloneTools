#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

apk update
apk add --no-cache alpine-sdk curl

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

echo "::endgroup::"

rustup target add x86_64-unknown-linux-musl
