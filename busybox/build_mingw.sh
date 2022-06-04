#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

tool_name="busybox.exe"
tool_version="FRP-4621-gf3c5e8bc3"
echo "::set-output name=tool_name::$tool_name"
echo "::set-output name=tool_version::$tool_version"

download_url="https://github.com/rmyorston/busybox-w32/archive/refs/tags/$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

mkdir -p "$dp0/release" && cd "$dp0/release"
wget "$download_url" -O "tool-$tool_version.tar.gz"
tar -xf "tool-$tool_version.tar.gz" && cd "busybox-w32-$tool_version"

echo "::endgroup::"

echo "::group::build"

make -j$(nproc) mingw64_defconfig
make -j$(nproc) AR=x86_64-w64-mingw32-gcc-ar STRIP=strip WINDRES=windres busybox.exe

echo "::endgroup::"

mkdir "$dp0/release/build" && cd "$dp0/release/build"
cp -f "$dp0/release/$tool_name" "$dp0/release/build/"

{ printf 'SHA-256: %s
%s
%s
' "$(sha256sum $tool_name)" "$("./$tool_name" --version)" "$download_url"
} > build-mingw.md

cat build-mingw.md

tar -czvf ../build-mingw.tar.gz .
