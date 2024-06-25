#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

apk update
apk add --no-cache alpine-sdk make linux-headers

echo "::endgroup::"

tool_name="busybox"
# version_tests: no_tool_version
tool_version="1.36.1"

download_url="https://busybox.net/downloads/busybox-$tool_version.tar.bz2"
echo "::group::prepare sources $download_url"

mkdir -p "$dp0/release/build" && cd "$dp0/release"
wget "$download_url" -O "tool-$tool_version.tar.gz"
tar -xf "tool-$tool_version.tar.gz" && cd "busybox-$tool_version"

echo "::endgroup::"

echo "::group::build"

make -j$(nproc) defconfig
sed -e 's/.*STATIC[^_].*/CONFIG_STATIC=y/' -i .config
make -j$(nproc) busybox

echo "::endgroup::"

cp -f "./$tool_name" "$dp0/release/build/"

cd "$dp0/release/build"

strip "./$tool_name"

{ printf '
SHA-256: %s
%s
' "$(sha256sum $tool_name)" "$download_url"
} > build-musl.md

cat build-musl.md

tar -czvf ../build-musl.tar.gz .
