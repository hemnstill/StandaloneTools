#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

apk update
apk add --no-cache alpine-sdk linux-headers zlib-dev zlib-static postgresql-dev perl-dev bison flex mingw-w64-gcc icu-dev

echo "::endgroup::"

tool_name="pg_dump.exe"
tool_version="REL_14_4"
echo "::set-output name=tool_name::$tool_name"
echo "::set-output name=tool_version::$tool_version"

download_url="https://github.com/postgres/postgres/archive/refs/tags/$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

tool_root_path="$dp0/release/postgres-$tool_version"

mkdir -p "$dp0/release/build" && cd "$dp0/release"

if [[ ! -f "$tool_root_path/configure" ]]; then
  wget "$download_url" -O "tool-$tool_version.tar.gz" && tar -xf "tool-$tool_version.tar.gz"
fi

cd "$tool_root_path"

echo "::endgroup::"

echo "::group::build"

./configure --without-readline --without-zlib --with-system-tzdata=/usr/share/zoneinfo --host=x86_64-w64-mingw32
make -j$(nproc)

echo "::endgroup::"

cp "$tool_root_path/src/bin/pg_dump/pg_dump.exe" "$dp0/release/build/"
cp "$tool_root_path/src/bin/pg_dump/pg_dumpall.exe" "$dp0/release/build/"
cp "$tool_root_path/src/bin/pg_dump/pg_restore.exe" "$dp0/release/build/"
cp "$tool_root_path/src/interfaces/libpq/libpq.dll" "$dp0/release/build/"

cd "$dp0/release/build"

{ printf 'SHA-256: %s
%s
' "$(sha256sum $tool_name)" "$download_url"
} > build-mingw.md

cat build-mingw.md

tar -czvf ../build-mingw.tar.gz .
