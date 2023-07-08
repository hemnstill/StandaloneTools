#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

apk update
apk add --no-cache alpine-sdk perl make linux-headers

echo "::endgroup::"

tool_name="openssl"
tool_version="3.0.1"

download_url="https://github.com/openssl/openssl/archive/refs/tags/openssl-$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

mkdir -p "$dp0/release" && cd "$dp0/release"
wget "$download_url" -O "tool-$tool_version.tar.gz"
tar -xf "tool-$tool_version.tar.gz" && cd "openssl-openssl-$tool_version"

echo "::endgroup::"

echo "::group::build"

./Configure no-shared no-tests no-legacy LDFLAGS='--static' linux-x86_64
make

echo "::endgroup::"

mkdir "$dp0/release/build" && cd "$dp0/release/build"
cp -f "$dp0/release/openssl-openssl-$tool_version/apps/$tool_name" "$dp0/release/build/"
cp -f "$dp0/release/openssl-openssl-$tool_version/apps/openssl.cnf" "$dp0/release/build/"

strip "$tool_name"
chmod +x "$tool_name"

{ printf 'SHA-256: %s
%s
' "$(sha256sum $tool_name)" "$("./$tool_name" version)"
} > _musl.md

cat _musl.md

tar -czvf ../_musl.tar.gz .
