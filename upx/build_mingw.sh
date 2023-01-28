#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

echo "::endgroup::"

tool_name="upx"
tool_version="3.96"
self_name="$tool_name-$tool_version"

download_url="https://github.com/upx/upx/releases/download/v$tool_version/$self_name-win64.zip"
echo "::group::prepare sources $download_url"

mkdir -p "$dp0/release/build" && cd "$dp0/release"
rm -rf "$dp0/release/build/"*
wget "$download_url" -O "$self_name.zip"
export BB_OVERRIDE_APPLETS=tar
tar -xf "$self_name.zip" && cd "$self_name-win64"

echo "::endgroup::"

echo "::group::build"

cp ./upx.exe "$dp0/release/build/upx_packed.exe"
cp ./upx.exe "$dp0/release/build/upx.exe"
./upx -d "$dp0/release/build/upx.exe"

echo "::endgroup::"

cd "$dp0/release/build"

{ printf '
SHA-256: %s
%s

' "$(sha256sum "./$tool_name")" "$download_url"
} > build-mingw.md

cat build-mingw.md

tar -czvf ../build-mingw.tar.gz .