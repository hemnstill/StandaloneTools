#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

tool_name="zstd"
tool_version="1.5.5"
self_toolset_name="build-mingw"

download_url="https://github.com/facebook/zstd/archive/refs/tags/v$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

mkdir -p "$dp0/release/build" && cd "$dp0/release"
wget "$download_url" -O "tool-$tool_version.tar.gz"
tar -xf "tool-$tool_version.tar.gz" && cd "$tool_name-$tool_version"

echo "::endgroup::"

echo "::group::build"

git clone --depth 1 --branch v1.2.11 https://github.com/madler/zlib
msys2 make -C zlib -f win32/Makefile.gcc libz.a

export CPPFLAGS=-I../zlib
export LDFLAGS=../zlib/libz.a
msys2 make -j allzstd MOREFLAGS=-static V=1

cp -f "./$tool_name.exe" "$dp0/release/build/"

cd "$dp0/release/build"

{ printf '### %s
SHA-256: %s
%s
%s
' "$self_toolset_name.tar.gz" "$(sha256sum $tool_name)" "$("./$tool_name" --version)" "$download_url"
} > "$self_toolset_name.md"

cat "$self_toolset_name.md"

tar -czvf "../$self_toolset_name.tar.gz" .
