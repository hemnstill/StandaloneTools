#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

#apk update
#apk add --no-cache alpine-sdk linux-headers pcre2-dev mingw-w64-gcc

echo "::endgroup::"

tool_name="pcre2grep.exe"
tool_version="10.39"
echo "::set-output name=tool_name::$tool_name"
echo "::set-output name=tool_version::$tool_version"

download_url="https://github.com/PhilipHazel/pcre2/releases/download/pcre2-$tool_version/pcre2-$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

mkdir -p "$dp0/release/build" && cd "$dp0/release"
wget "$download_url" -O "pcre2-$tool_version.tar.gz"
tar -xf "pcre2-$tool_version.tar.gz" && cd "pcre2-$tool_version"

echo "::endgroup::"

echo "::group::build"

cmake -DPCRE2_SUPPORT_JIT=ON -DPCRE2_BUILD_PCRE2_16=ON -DPCRE2_BUILD_PCRE2_32=ON -B build -A Win32

cmake --build build --config Release

echo "::endgroup::"

cp -f "$dp0/release/pcre2-$tool_version/build/Release/$tool_name" "$dp0/release/build"

cd "$dp0/release/build"

{ printf 'SHA-256: %s
%s' "$(sha256sum $tool_name)" "$download_url"
} > build-mingw.md

cat build-mingw.md

tar -czvf ../build-mingw.tar.gz .
