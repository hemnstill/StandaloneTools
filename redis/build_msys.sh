#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e


tool_name="redis"
tool_version="7.2.1"
self_toolset_name="build-msys"
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

sed -i 's/__GNU_VISIBLE/1/' D:/a/_temp/msys64/usr/include/dlfcn.h

export BB_OVERRIDE_APPLETS=make

msys2 make BUILD_TLS=yes

echo "::endgroup::"

find ./src -mindepth 1 -maxdepth 1 \( -name '*.dll' -or -name '*.exe' \) -exec cp -f "{}" "$release_version_dirpath/" \;

cd "$release_version_dirpath"

find . -mindepth 1 -maxdepth 1 -exec strip "{}" \;

{ printf '### %s
%s

SHA-256: %s

' "$self_toolset_name.tar.gz" "$(./redis-cli --version)" "$(sha256sum ./*)"
} > "$self_toolset_name.md"

cat "$self_toolset_name.md"

"$bsdtar" -czvf "../$self_toolset_name.tar.gz" .
