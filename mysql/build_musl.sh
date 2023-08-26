#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

apk update
apk add --no-cache alpine-sdk linux-headers cmake
apk add --no-cache build-base autoconf openssl-dev ncurses-dev
apk add --no-cache libaio-dev eudev-dev openldap-dev

echo "::endgroup::"

tool_name="mysql"
tool_version="8.1.0"
self_toolset_name="build-musl"
release_version_dirpath="$dp0/release/build"

mkdir -p "$release_version_dirpath" && cd "$dp0/release"

download_url="https://github.com/mysql/mysql-server/archive/refs/tags/$tool_name-$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

"$dp0/../.tools/download_bsdtar.sh"
bsdtar="$dp0/release/bsdtar"

wget "$download_url" -O "tool-$tool_version.tar.gz"
"$bsdtar" -xf "tool-$tool_version.tar.gz" && cd "mysql-server-mysql-$tool_version"

patch "./libmysql/dns_srv.cc" "$dp0/release/mysql-connector-c-8.0.27-res_n.patch"
patch "./sql/memory/aligned_atomic.h" "$dp0/release/_cache_line_size.patch"

echo "::endgroup::"

echo "::group::build"

cmake . -LH \
  -DDOWNLOAD_BOOST=1 \
  -DWITH_BOOST=./boost \
  -DFORCE_INSOURCE_BUILD=1 \
  -DWITHOUT_SERVER=1 \
  -DWITH_EMBEDDED_SHARED_LIBRARY=1 \
  -DWITH_UNIT_TESTS=0 \
  -DWITH_BUILD_ID=0 \
  -DREPRODUCIBLE_BUILD=1 \
  -DBUILD_CONFIG=mysql_release

make

cp -rf "../runtime_output_directory/." "$release_version_dirpath/"

cd "$release_version_dirpath"

{ printf '%s
### %s

%s
' "$("./$tool_name" version)" "$self_toolset_name.tar.gz" "$(sha256sum ./*)"
} > "$self_toolset_name.md"

cat "$self_toolset_name.md"

tar -czvf "../$self_toolset_name.tar.gz" .

echo "::endgroup::"
