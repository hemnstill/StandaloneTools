#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

export DEBIAN_FRONTEND=noninteractive
apt update
apt install -y cmake build-essential wget curl patchelf gcc g++ execline

echo "::endgroup::"

tool_name="p7zip-zstd"
tool_version="22.00"
self_toolset_name="build-gnu"
release_version_dirpath="$dp0/release/build"
commit_id=36f6b7422234c8c48d3eaaa80a0e8ceb1180f081
source_dirpath="$dp0/release/p7zip-$commit_id"

mkdir -p "$release_version_dirpath" && cd "$dp0/release"

download_url="https://github.com/p7zip-project/p7zip/archive/$commit_id.tar.gz"
echo "::group::prepare sources $download_url"

"$dp0/../.tools/download_bsdtar.sh"
bsdtar="$dp0/release/bsdtar"

curl --location "$download_url" --output "tool-$tool_version.tar.xz"
"$bsdtar" -xf "tool-$tool_version.tar.xz" && cd "$source_dirpath"

# patch "$source_dirpath/CPP/7zip/7zip_gcc.mak" "$dp0/release/0001-static.patch"

echo "::endgroup::"

echo "::group::build"

cd "$source_dirpath/CPP/7zip/Bundles/Alone2"
make -f makefile.gcc
cp -vf "./_o/bin/7zz" "$release_version_dirpath/"
cp -vr "./_o/lib/" "$release_version_dirpath/"

ls -R "./_o"

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
