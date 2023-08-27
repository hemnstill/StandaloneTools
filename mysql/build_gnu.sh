#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

export DEBIAN_FRONTEND=noninteractive

echo "::group::install deps"

apt update
apt install -y build-essential cmake wget
apt install -y libaio-dev libudev-dev libssl-dev ncurses-dev libc6-dev

echo "::endgroup::"

tool_name="mysql"
tool_version="8.0.33"
self_toolset_name="build-gnu"
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
  -DDOWNLOAD_BOOST=1 \
  -DWITH_BOOST=./boost \
  -DFORCE_INSOURCE_BUILD=1 \
  -DWITHOUT_SERVER=1 \
  -DBUILD_SHARED_LIBS=0 \
  -DCMAKE_EXE_LINKER_FLAGS="-lssl -lcrypto" \
  -DWITH_UNIT_TESTS=0 \
  -DWITH_BUILD_ID=0 \
  -DREPRODUCIBLE_BUILD=1 \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_CONFIG=mysql_release

find . -type f -mindepth 2 -maxdepth 5 -name "link.txt" \
  -exec echo replace '.so' "{}" \; \
  -exec sed -i -e 's@/usr/lib/x86_64-linux-gnu/libssl.so@/usr/lib/x86_64-linux-gnu/libssl.a@g' \
            -e 's@/usr/lib/x86_64-linux-gnu/libcrypto.so@/usr/lib/x86_64-linux-gnu/libcrypto.a@g' "{}" \;

cmake --build . --config Release

echo "::endgroup::"

cp -rf "./runtime_output_directory/." "$release_version_dirpath/"

cd "$release_version_dirpath"

find . -mindepth 1 -maxdepth 1 -name '*test*' -exec rm -f "{}" \;
find . -mindepth 1 -maxdepth 1 ! -name "mysql*" -exec rm -f "{}" \;
find . -mindepth 1 -maxdepth 1 -exec strip "{}" \;

ldd "$tool_name"

{ printf '### %s

%s

<details>
  <summary>ldd mysql</summary>

```
%s
```
</details>

<details>
  <summary>sha256sum ./*</summary>

```
%s
```
</details>

' "$self_toolset_name.tar.gz" "$("./$tool_name" --version)" "$(ldd "$tool_name")" "$(sha256sum ./*)"
} > "$self_toolset_name.md"

cat "$self_toolset_name.md"

tar -czvf "../$self_toolset_name.tar.gz" .

