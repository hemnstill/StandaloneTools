#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

apk update
apk add --no-cache alpine-sdk linux-headers cmake
apk add --no-cache build-base autoconf openssl-dev ncurses-dev
apk add --no-cache libaio-dev

echo "::endgroup::"

tool_name="mysql"
tool_version="8.0.33"
self_toolset_name="build-musl"
release_version_dirpath="$dp0/release/build"

mkdir -p "$release_version_dirpath" && cd "$dp0/release"

download_url="https://github.com/mysql/mysql-server/archive/refs/tags/$tool_name-$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

"$dp0/../.tools/download_bsdtar.sh"
bsdtar="$dp0/release/bsdtar"

wget "$download_url" -O "tool-$tool_version.tar.gz"
"$bsdtar" -xf "tool-$tool_version.tar.gz" && cd "mysql-server-mysql-$tool_version"

echo "::endgroup::"

echo "::group::build"

cmake . -LH -DDOWNLOAD_BOOST=ON -DFORCE_INSOURCE_BUILD=ON -DWITHOUT_SERVER=ON -DWITH_EMBEDDED_SHARED_LIBRARY=ON -DBUILD_CONFIG=mysql_release

echo "::endgroup::"
