#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

apk update
apk add --no-cache alpine-sdk zlib-dev zlib-static xz-dev zstd-dev zstd-static

echo "::endgroup::"

tool_name="zstd"
tool_version="1.5.5"
self_toolset_name="build-musl"

download_url="https://github.com/facebook/zstd/archive/refs/tags/v$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

mkdir -p "$dp0/release" && cd "$dp0/release"
wget "$download_url" -O "tool-$tool_version.tar.gz"
tar -xf "tool-$tool_version.tar.gz" && cd "$tool_name-$tool_version"

echo "::endgroup::"

echo "::group::build"

make
