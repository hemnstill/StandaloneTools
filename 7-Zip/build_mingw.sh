#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

tool_name="7-Zip"
tool_version="24.08"
self_toolset_name="build-mingw"
release_version_dirpath="$dp0/release/build"

# shellcheck disable=SC2001
tool_version_digits_only="$(echo $tool_version | sed -e 's/\.//g')"

mkdir -p "$release_version_dirpath" && cd "$dp0/release"

download_url="https://www.7-zip.org/a/7z$tool_version_digits_only-src.tar.xz"
echo "::group::prepare sources $download_url"

"$dp0/../.tools/download_bsdtar.sh"
bsdtar="$dp0/release/bsdtar"

# wget failed: ssl_client: TLS error from peer (alert code 80): 80
curl --location "$download_url" --output "tool-$tool_version.tar.xz"
"$bsdtar" -xf "tool-$tool_version.tar.xz"

echo "::endgroup::"

echo "::group::build"

cd "$dp0/release/CPP/7zip/Bundles/Alone2"
nmake
cp -f "./x64/7zz.exe" "$release_version_dirpath/"

echo "::endgroup::"

cd "$release_version_dirpath"

strip 7zz.exe

{ printf '### %s
%s

SHA-256: %s

<details>
  <summary>7zz i</summary>

```
%s
```
</details>

%s

' "$self_toolset_name.tar.gz" "$(./7zz.exe | head -2)" "$(sha256sum 7zz.exe)" "$(./7zz.exe i)" "$download_url"
} > "$self_toolset_name.md"

cat "$self_toolset_name.md"

"$bsdtar" -czvf "../$self_toolset_name.tar.gz" .
