#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

tool_name="pcre2grep.exe"
tool_version="10.40"
echo "::set-output name=tool_name::$tool_name"
echo "::set-output name=tool_version::$tool_version"

download_url="https://github.com/PCRE2Project/pcre2/releases/download/pcre2-$tool_version/pcre2-$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

mkdir -p "$dp0/release/build" && cd "$dp0/release"
wget "$download_url" -O "pcre2-$tool_version.tar.gz"
tar -xf "pcre2-$tool_version.tar.gz" && cd "pcre2-$tool_version"

echo "::endgroup::"

echo "::group::build"

cmake -DPCRE2_SUPPORT_JIT=ON -DPCRE2_BUILD_PCRE2_16=ON -DPCRE2_BUILD_PCRE2_32=ON -B build -DPCRE2_STATIC_RUNTIME=ON

cmake --build build --config Release

echo "::endgroup::"

cp -f "$dp0/release/pcre2-$tool_version/build/Release/$tool_name" "$dp0/release/build"

cd "$dp0/release/build"

{ printf 'SHA-256: %s (msvc)
' "$(sha256sum $tool_name)"
} > build-msvc.md

cat build-msvc.md

tar -czvf ../build-msvc.tar.gz .
