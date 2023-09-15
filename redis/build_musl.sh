#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

apk update
apk add --no-cache alpine-sdk make linux-headers

echo "::endgroup::"

tool_name="redis"
tool_version="7.2.1"
self_toolset_name="build-musl"
release_version_dirpath="$dp0/release/build"

mkdir -p "$release_version_dirpath" && cd "$dp0/release"

download_url="https://github.com/redis/redis/archive/refs/tags/$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

"$dp0/../.tools/download_bsdtar.sh"
bsdtar="$dp0/release/bsdtar"

wget "$download_url" -O "tool-$tool_version.tar.gz"
"$bsdtar" -xf "tool-$tool_version.tar.gz" && cd "redis-$tool_version"

echo "::endgroup::"

echo "::group::build"

make

echo "::endgroup::"

cd "$release_version_dirpath"

{ printf '### %s
%s

SHA-256: %s

<details>
  <summary>7zz i</summary>

```
%s
```
</details>

' "$self_toolset_name.tar.gz" "$(./redis-cli --version)" "$(sha256sum redis-cli)" "$(./redis-cli i)"
} > "$self_toolset_name.md"

cat "$self_toolset_name.md"

"$bsdtar" -czvf "../$self_toolset_name.tar.gz" .
