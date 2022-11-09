#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

apk update
apk add --no-cache alpine-sdk make linux-headers mingw-w64-gcc

echo "::endgroup::"

tool_name="busybox.exe"
tool_version="FRP-4784-g5507c8744"
echo "::set-output name=tool_name::$tool_name"
echo "::set-output name=tool_version::$tool_version"

download_url="https://github.com/rmyorston/busybox-w32/archive/refs/tags/$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

mkdir -p "$dp0/release/build" && cd "$dp0/release"
wget "$download_url" -O "tool-$tool_version.tar.gz"
tar -xf "tool-$tool_version.tar.gz" && cd "busybox-w32-$tool_version"

echo "::endgroup::"

echo "::group::build"

make -j$(nproc) mingw64_defconfig
make -j$(nproc) busybox.exe

echo "::endgroup::"

cp -f "./$tool_name" "$dp0/release/build/"

cd "$dp0/release/build"

{ printf '
%s
SHA-256: %s
%s
' "$(./$tool_name | head -2)" "$(sha256sum $tool_name)" "$download_url"
} > build-mingw.md

cat build-mingw.md

tar -czvf ../build-mingw.tar.gz .
