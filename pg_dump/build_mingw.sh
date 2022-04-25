#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

apk update
apk add --no-cache alpine-sdk linux-headers zlib-dev zlib-static postgresql-dev perl-dev bison flex mingw-w64-gcc icu-dev

echo "::endgroup::"

tool_name="pg_dump.exe"
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

./configure --without-readline --without-zlib --with-system-tzdata=/usr/share/zoneinfo --host=x86_64-w64-mingw32 CFLAGS="-O3 -fPIC" CXXFLAGS="-fPIC" CPPFLAGS="-fPIC"
make -j$(nproc)

echo "::endgroup::"

mkdir "$dp0/release/build"

cp -rf "$dp0/release/postgres-$tool_version/src/bin/pg_dump/*.exe" "$dp0/release/build/"
cp -rf "$dp0/release/postgres-$tool_version/src/interfaces/libpq/*.dll" "$dp0/release/build/"

cd "$dp0/release/build"

{ printf 'SHA-256: %s
' "$(sha256sum $tool_name)"
} > build-mingw.md

cat build-mingw.md

tar -czvf ../build-mingw.tar.gz .
