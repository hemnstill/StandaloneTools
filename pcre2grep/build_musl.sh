#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

apk update
apk add --no-cache alpine-sdk pcre2-dev

echo "::endgroup::"

tool_name="pcre2grep"
tool_version="10.40"
echo "::set-output name=tool_name::$tool_name"
echo "::set-output name=tool_version::$tool_version"

download_url="https://github.com/PhilipHazel/pcre2/releases/download/pcre2-$tool_version/pcre2-$tool_version.tar.gz"
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

{ printf 'SHA-256: %s
%s
%s' "$(sha256sum < $tool_name)" "$("./$tool_name" --version)" "$download_url"
} > build-musl.md

cat build-musl.md

tar -czvf ../build-musl.tar.gz .
