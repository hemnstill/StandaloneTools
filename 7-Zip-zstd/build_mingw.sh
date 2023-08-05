#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

tool_name="7-Zip-zstd"
tool_version="22.01-v1.5.5"
self_toolset_name="build-mingw"
self_name="$tool_name-$tool_version"
release_version_dirpath="$dp0/release/build"

mkdir -p "$release_version_dirpath" && cd "$dp0/release"

download_url="https://github.com/mcmilk/7-Zip-zstd/archive/refs/tags/v$tool_version-R3.tar.gz"
echo "::group::prepare sources $download_url"

"$dp0/../.tools/download_bsdtar.sh"
bsdtar="$dp0/release/bsdtar"

mkdir -p "$dp0/release" && cd "$dp0/release"
wget "$download_url" -O "tool-$tool_version.tar.gz"
tar -xf "tool-$tool_version.tar.gz" && cd "7-Zip-zstd-$tool_version-R3"

echo "::endgroup::"


echo "::group::build"

cd "./CPP/7zip/Bundles/Format7zF"
nmake

echo "::endgroup::"

ls -R

{ printf '### %s
SHA-256: %s
%s

' "$self_toolset_name.tar.gz" "$(sha256sum $tool_name)" "$download_url"
} > "$self_toolset_name.md"

cat "$self_toolset_name.md"

"$bsdtar" -czvf "../$self_toolset_name.tar.gz" .