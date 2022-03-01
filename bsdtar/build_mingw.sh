#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

tool_name="bsdtar"
tool_version="3.5.1"
echo "::set-output name=tool_name::$tool_name"
echo "::set-output name=tool_version::$tool_version"

download_url="https://github.com/libarchive/libarchive/releases/download/v3.5.1/libarchive-$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

mkdir -p "$dp0/release" && cd "$dp0/release"
wget "$download_url" -O "libarchive-$tool_version.tar.gz"
tar -xf "libarchive-$tool_version.tar.gz" && cd "libarchive-$tool_version"

echo "::endgroup::"

echo "::group::build"

export BE=mingw-gcc

"$dp0/ci.cmd" deplibs
"$dp0/ci.cmd" configure
"$dp0/ci.cmd" build
"$dp0/ci.cmd" artifact

echo "::endgroup::"
