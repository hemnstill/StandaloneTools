#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

apk update
apk add --no-cache alpine-sdk linux-headers zlib-dev zlib-static postgresql-dev perl-dev bison flex libpq-dev

echo "::endgroup::"

tool_name="pg_dump"
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

cp "$dp0/release/Makefile" "$tool_root_path/src/bin/pg_dump/"

cd "$tool_root_path"

echo "::endgroup::"

echo "::group::build"

./configure --without-readline --without-zlib

make -j$(nproc)

echo "::endgroup::"

cp "$tool_root_path/src/bin/pg_dump/pg_dump" "$dp0/release/build/"
cp "$tool_root_path/src/bin/pg_dump/pg_dumpall" "$dp0/release/build/"
cp "$tool_root_path/src/bin/pg_dump/pg_restore" "$dp0/release/build/"

cd "$dp0/release/build"

strip "$tool_name"
strip "pg_dumpall"
strip "pg_restore"

chmod +x "$tool_name"
chmod +x "pg_dumpall"
chmod +x "pg_restore"

{ printf 'SHA-256: %s
%s
' "$(sha256sum $tool_name)" "$("./$tool_name" --version)"
} > build-musl.md

cat build-musl.md

tar -czvf ../build-musl.tar.gz .
