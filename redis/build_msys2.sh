#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

tool_name="redis"
tool_version="7.0.13"
self_toolset_name="build-msys2"
release_version_dirpath="$dp0/release/build"

mkdir -p "$release_version_dirpath" && cd "$dp0/release"

download_url="https://github.com/redis/redis/archive/refs/tags/$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

"$dp0/../.tools/download_bsdtar.sh"
bsdtar="$dp0/release/bsdtar"

wget "$download_url" -O "tool-$tool_version.tar.gz"
"$bsdtar" -xf "tool-$tool_version.tar.gz" && cd "$tool_name-$tool_version"

echo "::endgroup::"

echo "::group::build"

sed -i 's/__GNU_VISIBLE/1/' /d/a/_temp/msys64/usr/include/dlfcn.h

make BUILD_TLS=yes

echo "::endgroup::"

cp -f /d/a/_temp/msys64/usr/bin/msys-2.0.dll "$release_version_dirpath/"
cp -f /d/a/_temp/msys64/usr/bin/msys-crypto-3.dll "$release_version_dirpath/"
cp -f /d/a/_temp/msys64/usr/bin/msys-ssl-3.dll "$release_version_dirpath/"

find ./src -mindepth 1 -maxdepth 1 -name '*.exe' -exec cp -f "{}" "$release_version_dirpath/" \;

cd "$release_version_dirpath"

find . -mindepth 1 -maxdepth 1 -exec strip "{}" \;

{ printf '### %s
%s

<details>
  <summary>sha256sum ./*</summary>

```
%s
```
</details>

%s

' "$self_toolset_name.tar.gz" "$(./redis-cli --version)" "$(sha256sum ./*)" "$download_url"
} > "$self_toolset_name.md"

cat "$self_toolset_name.md"

"$bsdtar" -czvf "../$self_toolset_name.tar.gz" .
