#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

apk update
apk add --no-cache alpine-sdk linux-headers zlib-dev zlib-static postgresql-dev perl-dev bison flex libpq-dev

echo "::endgroup::"

tool_name="pg_dump"
# version_tests: no_tool_version
tool_version="REL_15_1"

download_url="https://github.com/postgres/postgres/archive/refs/tags/$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

tool_root_path="$dp0/release/postgres-$tool_version"

mkdir -p "$dp0/release/build" && cd "$dp0/release"

if [[ ! -f "$tool_root_path/configure" ]]; then
  wget "$download_url" -O "tool-$tool_version.tar.gz" && tar -xf "tool-$tool_version.tar.gz"
fi

patch "$tool_root_path/src/bin/pg_dump/Makefile" "$dp0/pg_dump_static_patch.diff"
patch "$tool_root_path/src/bin/psql/Makefile" "$dp0/psql_static_patch.diff"

cd "$tool_root_path"

echo "::endgroup::"

echo "::group::build"

./configure --without-readline --without-zlib

make -j$(nproc)

echo "::endgroup::"

cp "$tool_root_path/src/bin/pg_dump/pg_dump" "$dp0/release/build/"
cp "$tool_root_path/src/bin/pg_dump/pg_dumpall" "$dp0/release/build/"
cp "$tool_root_path/src/bin/pg_dump/pg_restore" "$dp0/release/build/"
cp "$tool_root_path/src/bin/psql/psql" "$dp0/release/build/"

cd "$dp0/release/build"

strip "$tool_name"
strip "pg_dumpall"
strip "pg_restore"
strip "psql"

chmod +x "$tool_name"
chmod +x "pg_dumpall"
chmod +x "pg_restore"
chmod +x "psql"

{ printf '%s
%s
%s

%s
' "$("./$tool_name" --version)" "$("./pg_restore" --version)" "$("./psql" --version)" "$(sha256sum ./*)"
} > build-musl.md

cat build-musl.md

tar -czvf ../build-musl.tar.gz .
