#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

tool_name="openssl.exe"
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

perl ./Configure mingw64 --cross-compile-prefix=x86_64-w64-mingw32- no-shared LDFLAGS='--static' no-makedepend
perl configdata.pm --dump

nmake /S

echo "::endgroup::"

mkdir "$dp0/release/build" && cd "$dp0/release/build"
cp -f "$dp0/release/openssl-OpenSSL_$tool_version/apps/$tool_name" "$dp0/release/build/"

{ printf 'SHA-256: %s
%s
%s
' "$(sha256sum < $tool_name)" "$("./$tool_name" version)" "$download_url"
} > _mingw.md

cat _mingw.md

tar -czvf ../_mingw.tar.gz .
