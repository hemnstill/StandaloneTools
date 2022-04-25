#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

apk update
apk add --no-cache alpine-sdk linux-headers zlib-dev zlib-static postgresql-dev perl-dev bison flex

echo "::endgroup::"

tool_name="pg_dump"
tool_version="REL_14_2"
echo "::set-output name=tool_name::$tool_name"
echo "::set-output name=tool_version::$tool_version"

download_url="https://github.com/postgres/postgres/archive/refs/tags/$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

mkdir -p "$dp0/release" && cd "$dp0/release"
wget "$download_url" -O "tool-$tool_version.tar.gz" && tar -xf "tool-$tool_version.tar.gz"
cd "postgres-$tool_version"

echo "::endgroup::"

echo "::group::build"

mkdir -p "$dp0/release/build"
cd "$dp0/release/build"
"$dp0/release/postgres-$tool_version/configure" --without-readline --without-zlib CFLAGS="-fPIC" CXXFLAGS="-fPIC" CPPFLAGS="-fPIC" --enable-static
make -j$(nproc)

echo "::endgroup::"

#mkdir "$dp0/release/build"
#
#cp -rf "$dp0/release/postgres-$tool_version/src/bin/pg_dump/." "$dp0/release/build/"
#
#cd "$dp0/release/build"

strip "$tool_name"
chmod +x "$tool_name"

{ printf 'SHA-256: %s
%s
' "$(sha256sum $tool_name)" "$("./$tool_name" --version)"
} > build-musl.md

cat build-musl.md

tar -czvf ../build-musl.tar.gz .
