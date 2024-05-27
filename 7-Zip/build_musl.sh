#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

apk update
apk add --no-cache alpine-sdk make linux-headers

echo "::endgroup::"

tool_name="7-Zip"
tool_version="24.06"
self_toolset_name="build-musl"
release_version_dirpath="$dp0/release/build"

mkdir -p "$release_version_dirpath" && cd "$dp0/release"

download_url="https://www.7-zip.org/a/7z2406-src.tar.xz"
echo "::group::prepare sources $download_url"

"$dp0/../.tools/download_bsdtar.sh"
bsdtar="$dp0/release/bsdtar"

# wget failed: ssl_client: TLS error from peer (alert code 80): 80
curl --location "$download_url" --output "tool-$tool_version.tar.xz"
"$bsdtar" -xf "tool-$tool_version.tar.xz"

git apply "$dp0/release/0001-static.patch"

echo "::endgroup::"

echo "::group::build"

cd "$dp0/release/CPP/7zip/Bundles/Alone2"
make -j -f makefile.gcc
cp -f "./_o/7zz" "$release_version_dirpath/"

echo "::endgroup::"

cd "$release_version_dirpath"

strip 7zz

{ printf '### %s
%s

SHA-256: %s

<details>
  <summary>7zz i</summary>

```
%s
```
</details>

' "$self_toolset_name.tar.gz" "$(./7zz | head -2)" "$(sha256sum 7zz)" "$(./7zz i)"
} > "$self_toolset_name.md"

cat "$self_toolset_name.md"

"$bsdtar" -czvf "../$self_toolset_name.tar.gz" .
