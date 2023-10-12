#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

tool_name="zstd"
tool_version="1.5.5"
self_toolset_name="build-mingw"

download_url="https://github.com/facebook/zstd/archive/refs/tags/v$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

mkdir -p "$dp0/release/build" && cd "$dp0/release"

"$dp0/../.tools/download_bsdtar.sh"
bsdtar="$dp0/release/bsdtar"

wget "$download_url" -O "tool-$tool_version.tar.gz"
"$bsdtar" -xf "tool-$tool_version.tar.gz"

echo "::endgroup::"

echo "::group::build"

git clone --depth 1 --branch v1.3 https://github.com/madler/zlib
make -C zlib -f win32/Makefile.gcc libz.a

cd "$dp0/release/$tool_name-$tool_version"
export CPPFLAGS=-I"$dp0/release/zlib"
export LDFLAGS="$dp0/release/zlib/libz.a"
make -j allzstd MOREFLAGS=-static V=1

cp -f "./programs/$tool_name.exe" "$dp0/release/build/"

cd "$dp0/release/build"

{ printf '### %s
SHA-256: %s
%s


%s
' "$self_toolset_name.tar.gz" "$(sha256sum $tool_name)" "$("./$tool_name" --version)" "$download_url"
} > "$self_toolset_name.md"

cat "$self_toolset_name.md"

tar -czvf "../$self_toolset_name.tar.gz" .