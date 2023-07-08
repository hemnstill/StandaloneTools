#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

apk update
apk add --no-cache alpine-sdk perl make linux-headers mingw-w64-gcc

echo "::endgroup::"

tool_name="openssl.exe"
tool_version="3.1.1"
self_toolset_name="build-mingw"
self_name="$tool_name-$tool_version"
release_version_dirpath="$dp0/release/$self_name"

mkdir -p "$release_version_dirpath" && cd "$dp0/release"

download_url="https://github.com/openssl/openssl/archive/refs/tags/openssl-$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

"$dp0/../.tools/download_bsdtar.sh"
bsdtar="$dp0/release/bsdtar"

wget "$download_url" -O "tool-$tool_version.tar.gz"
"$bsdtar" -xf "tool-$tool_version.tar.gz" && cd "openssl-openssl-$tool_version"

echo "::endgroup::"

echo "::group::build"

./Configure mingw64 --cross-compile-prefix=x86_64-w64-mingw32- no-tests no-shared no-module enable-legacy
make

echo "::endgroup::"

cd "$release_version_dirpath"
cp -f "$dp0/release/openssl-openssl-$tool_version/apps/$tool_name" "$release_version_dirpath/"
cp -f "$dp0/release/openssl-openssl-$tool_version/apps/openssl.cnf" "$release_version_dirpath/"

{ printf '### %s
SHA-256: %s
%s

' "$self_toolset_name.tar.gz" "$(sha256sum $tool_name)" "$download_url"
} > "$self_toolset_name.md"

cat "$self_toolset_name.md"

"$bsdtar" -czvf "../$self_toolset_name.tar.gz" .
