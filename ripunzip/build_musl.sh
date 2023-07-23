#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

apk update
apk add --no-cache alpine-sdk rustup

echo "::endgroup::"

rustup target add x86_64-unknown-linux-musl
