#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

echo "::endgroup::"

tool_name="mysql"
tool_version="8.4.0"
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

cmake . \
  -DWITH_SSL=C:/vcpkg/packages/openssl_x64-windows \
  -DDOWNLOAD_BOOST=1 \
  -DWITH_BOOST=./boost \
  -DFORCE_INSOURCE_BUILD=1 \
  -DWITHOUT_SERVER=1 \
  -DBUILD_SHARED_LIBS=0 \
  -DWITH_UNIT_TESTS=0 \
  -DREPRODUCIBLE_BUILD=1 \
  -G "Visual Studio 17 2022" \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_CONFIG=mysql_release

cmake --build . --config Release

cp -rf "./runtime_output_directory/Release/." "$release_version_dirpath/"

cd "$release_version_dirpath"

find . -mindepth 1 -maxdepth 1 \( -name '*test*' -or -name '*.pdb' \) -exec rm -f "{}" \;
find . -mindepth 1 -maxdepth 1 \( ! -name "mysql*" -and ! -name "lib*" \) -exec rm -f "{}" \;

{ printf '### %s

%s

<details>
  <summary>sha256sum ./*</summary>

```
%s
```
</details>

%s

' "$self_toolset_name.tar.gz" "$("./$tool_name" --version)" "$(sha256sum ./*)" "$download_url"
} > "$self_toolset_name.md"

cat "$self_toolset_name.md"

tar -czvf "../$self_toolset_name.tar.gz" .

