#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

apk update
apk add --no-cache alpine-sdk cmake zlib-dev zlib-static

echo "::endgroup::"

tool_name="zstd"
tool_version="1.5.5"
self_toolset_name="build-musl"

download_url="https://github.com/facebook/zstd/archive/refs/tags/v$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

mkdir -p "$dp0/release/build" && cd "$dp0/release"
wget "$download_url" -O "tool-$tool_version.tar.gz"
tar -xf "tool-$tool_version.tar.gz" && cd "$tool_name-$tool_version"

echo "::endgroup::"

echo "::group::build"

cmake build/cmake -DZSTD_BUILD_STATIC=ON -DZSTD_USE_STATIC_RUNTIME=ON -DZSTD_BUILD_TESTS=OFF -DCMAKE_EXE_LINKER_FLAGS="-static"
cmake --build .

echo "::endgroup::"

cp -f "./programs/$tool_name" "$dp0/release/build/"

cd "$dp0/release/build"

strip "$tool_name"

{ printf '%s

### %s
SHA-256: %s

%s
' "$("./$tool_name" --version)" "$self_toolset_name.tar.gz" "$(sha256sum $tool_name)" "$(apk info zlib-static --webpage)"
} > "$self_toolset_name.md"

cat "$self_toolset_name.md"

tar -czvf "../$self_toolset_name.tar.gz" .
