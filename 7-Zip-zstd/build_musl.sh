#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"
export DEBIAN_FRONTEND=noninteractive
apt update
apt install -y software-properties-common build-essential wget clang

echo "::endgroup::"

tool_name="7-Zip-zstd"
tool_version="22.01-v1.5.5-R3"
self_toolset_name="build-musl"
release_version_dirpath="$dp0/release/build"

# tool_dirpath="$dp0/release/7-Zip-zstd-$tool_version"
tool_dirpath="$dp0/release/7z2301-src.tar"

mkdir -p "$release_version_dirpath" && cd "$dp0/release"

download_url="https://github.com/mcmilk/7-Zip-zstd/archive/refs/tags/v$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

"$dp0/../.tools/download_bsdtar.sh"
bsdtar="$dp0/release/bsdtar"

mkdir -p "$dp0/release" && cd "$dp0/release"
cd "$tool_dirpath"

echo "::endgroup::"

echo "::group::build"

root="$tool_dirpath/CPP/7zip"

cd "$root/Bundles/Alone2"
make -j -f makefile.gcc DISABLE_RAR=1
#make -j -f ../../cmpl_clang.mak

ls -R

cp -f "./_o/7zz" "$release_version_dirpath/"

echo "::endgroup::"

cd "$release_version_dirpath"

strip 7zz
ldd 7zz

{ printf '### %s
%s

%s

' "$(./7zz | head -2)" "$self_toolset_name.tar.gz" "$download_url"
} > "$self_toolset_name.md"

cat "$self_toolset_name.md"

"$bsdtar" -czvf "../$self_toolset_name.tar.gz" .
