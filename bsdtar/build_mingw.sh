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

wget "https://github.com/libarchive/libarchive/raw/v$tool_version/build/ci/github_actions/ci.cmd" -O "ci.cmd"

echo "::endgroup::"

echo "::group::build"

export BE=mingw-gcc

"ci.cmd" deplibs
"ci.cmd" configure
"ci.cmd" build
"ci.cmd" artifact

echo "::endgroup::"

cp -f "$dp0/release/libarchive-$tool_version/libarchive.zip" "$dp0/release/"
