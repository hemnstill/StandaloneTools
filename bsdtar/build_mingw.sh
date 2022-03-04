#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

tool_name="bsdtar.exe"
tool_version="3.5.1"
echo "::set-output name=tool_name::$tool_name"
echo "::set-output name=tool_version::$tool_version"

download_url="https://github.com/libarchive/libarchive/releases/download/v$tool_version/libarchive-$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

mkdir -p "$dp0/release" && cd "$dp0/release"
wget "$download_url" -O "libarchive-$tool_version.tar.gz"
tar -xf "libarchive-$tool_version.tar.gz" && cd "libarchive-$tool_version"

wget "https://github.com/libarchive/libarchive/raw/v$tool_version/build/ci/github_actions/ci.cmd" -O "$dp0/ci.cmd"

echo "::endgroup::"

echo "::group::build"

export BE=mingw-gcc

"$dp0/ci.cmd" deplibs
"$dp0/ci.cmd" configure
"$dp0/ci.cmd" build

echo "::endgroup::"

cp -f "$dp0/release/libarchive-$tool_version/build_ci/cmake/bin/$tool_name" "$dp0/release/"

cd "$dp0/release"

{ printf 'SHA-256: %s
%s
%s' "$(sha256sum < $tool_name)" "$("./$tool_name" --version)" "$download_url"
} > bsdtar_mingw.md

cat bsdtar_mingw.md

tar -czvf ./bsdtar_mingw.tar.gz .
