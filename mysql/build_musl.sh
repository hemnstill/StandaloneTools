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
tool_version="8.0.27"
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

echo "::endgroup::"

echo "::group::build"

cmake . \
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

echo "::endgroup::"
