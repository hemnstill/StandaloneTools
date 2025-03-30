#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

apk update
apk add --no-cache alpine-sdk pcre2-dev

echo "::endgroup::"

tool_name="pcre2grep"
tool_version="10.45"
self_toolset_name="build-musl"

download_url="https://github.com/PCRE2Project/pcre2/releases/download/pcre2-$tool_version/pcre2-$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

mkdir -p "$dp0/release/build" && cd "$dp0/release"
wget "$download_url" -O "pcre2-$tool_version.tar.gz"
tar -xf "pcre2-$tool_version.tar.gz" && cd "pcre2-$tool_version"

echo "::endgroup::"

echo "::group::build"

./configure LDFLAGS='--static' --disable-shared --enable-jit --enable-pcre2-8 --enable-pcre2-16 --enable-pcre2-32

make -j$(nproc)

echo "::endgroup::"

cp -f "$dp0/release/pcre2-$tool_version/$tool_name" "$dp0/release/build"

cd "$dp0/release/build"
strip "$tool_name"
chmod +x "$tool_name"

{ printf '%s

### %s
SHA-256: %s

' "$("./$tool_name" --version)" "$self_toolset_name.tar.gz"  "$(sha256sum $tool_name)"
} > build-musl.md

cat build-musl.md

tar -czvf "../$self_toolset_name.tar.gz" .
