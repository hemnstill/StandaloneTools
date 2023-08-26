#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

echo "::endgroup::"

tool_name="mysql"
tool_version="8.1.0"
self_toolset_name="build-msvc"
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

cmake . -LH \
  -DDOWNLOAD_BOOST=1 \
  -DWITH_BOOST=./boost \
  -DFORCE_INSOURCE_BUILD=1 \
  -DWITHOUT_SERVER=1 \
  -DWITH_EMBEDDED_SHARED_LIBRARY=1 \
  -DBUILD_STATIC=1 \
  -DWITH_UNIT_TESTS=0 \
  -DWITH_BUILD_ID=0 \
  -DREPRODUCIBLE_BUILD=1 \
  -G "Visual Studio 16 2019" \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_CONFIG=mysql_release

cmake --build . --config Release

cp -rf "./runtime_output_directory/." "$release_version_dirpath/"


cd "$release_version_dirpath"

find . -mindepth 1 -maxdepth 1 -name '*test.exe' -exec rm -f "{}" \;

{ printf '%s
### %s

%s
' "$("./$tool_name" --version)" "$self_toolset_name.tar.gz" "$(sha256sum ./*)"
} > "$self_toolset_name.md"

cat "$self_toolset_name.md"

tar -czvf "../$self_toolset_name.tar.gz" .

echo "::endgroup::"
