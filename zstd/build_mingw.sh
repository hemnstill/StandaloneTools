#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

tool_name="zstd"
tool_version="1.5.5"
tool_zlib_version="1.3"
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

download_url_zlib="https://github.com/madler/zlib/archive/refs/tags/v$tool_zlib_version.tar.gz"
wget "$download_url_zlib" -O "tool-$tool_zlib_version.tar.gz"
"$bsdtar" -xf "tool-$tool_zlib_version.tar.gz"

make -C "zlib-$tool_zlib_version" -f win32/Makefile.gcc libz.a

cd "$dp0/release/$tool_name-$tool_version"
export CPPFLAGS=-I"$dp0/release/zlib-$tool_zlib_version"
export LDFLAGS="$dp0/release/zlib-$tool_zlib_version/libz.a"
make -j allzstd MOREFLAGS=-static V=1

echo "::endgroup::"

cp -f "./programs/$tool_name.exe" "$dp0/release/build/"

cd "$dp0/release/build"

{ printf '### %s
SHA-256: %s


%s
%s
' "$self_toolset_name.tar.gz" "$(sha256sum $tool_name)" "$download_url_zlib" "$download_url"
} > "$self_toolset_name.md"

cat "$self_toolset_name.md"

tar -czvf "../$self_toolset_name.tar.gz" .
