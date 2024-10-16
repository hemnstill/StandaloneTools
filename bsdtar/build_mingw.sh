#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

choco install mingw

echo "::endgroup::"

tool_name="bsdtar.exe"
tool_version="3.7.7"
self_toolset_name="build-mingw"

download_url="https://github.com/libarchive/libarchive/releases/download/v$tool_version/libarchive-$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

mkdir -p "$dp0/release" && cd "$dp0/release"
wget "$download_url" -O "libarchive-$tool_version.tar.gz"
tar -xf "libarchive-$tool_version.tar.gz" && cd "libarchive-$tool_version"

ci_download_url="https://raw.githubusercontent.com/libarchive/libarchive/v$tool_version/build/ci/github_actions/ci.cmd"
wget "$ci_download_url" -O "$dp0/ci.cmd"

patch "$dp0/ci.cmd" "$dp0/release/bdstar_remove_bzip2.diff"

echo "::endgroup::"

echo "::group::build"

export BE=mingw-gcc

"$dp0/ci.cmd" deplibs
"$dp0/ci.cmd" configure
"$dp0/ci.cmd" build

echo "::endgroup::"

mkdir "$dp0/release/build" && cd "$dp0/release/build"
cp -f "$dp0/release/libarchive-$tool_version/build_ci/cmake/bin/$tool_name" "."

{ printf '### %s
SHA-256: %s
%s
%s
' "$self_toolset_name.tar.gz" "$(sha256sum $tool_name)" "$("./$tool_name" --version)" "$download_url"
} > "$self_toolset_name.md"

cat "$self_toolset_name.md"

tar -czvf "../$self_toolset_name.tar.gz" .
