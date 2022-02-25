#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

apk update
apk add --no-cache alpine-sdk perl make linux-headers

echo "::endgroup::"

tool_name="openssl"
tool_version="1_1_1k"
echo "::set-output name=tool_name::$tool_name"
echo "::set-output name=tool_version::$tool_version"

download_url="https://github.com/openssl/openssl/archive/refs/tags/OpenSSL_$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

mkdir -p "$dp0/release" && cd "$dp0/release"
wget "$download_url" -O "tool-$tool_version.tar.gz"
tar -xf "tool-$tool_version.tar.gz" && cd "openssl-OpenSSL_$tool_version"

echo "::endgroup::"

echo "::group::build"

./Configure no-shared LDFLAGS='--static' linux-x86_64
make

echo "::endgroup::"

cp -f "$dp0/release/openssl-OpenSSL_$tool_version/apps/$tool_name" "$dp0/release/"

cd "$dp0/release"
strip "$tool_name"
chmod +x "$tool_name"

{ printf 'SHA-256: %s
%s
%s' "$(sha256sum < $tool_name)" "$("./$tool_name" version)" "$download_url"
} > body.md

cat body.md