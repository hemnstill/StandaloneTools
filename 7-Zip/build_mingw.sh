#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

tool_name="7-Zip"
tool_version="23.01"
self_toolset_name="build-mingw"
release_version_dirpath="$dp0/release/build"

mkdir -p "$release_version_dirpath" && cd "$dp0/release"

download_url="https://www.7-zip.org/a/7z2301-src.tar.xz"
echo "::group::prepare sources $download_url"

"$dp0/../.tools/download_bsdtar.sh"
bsdtar="$dp0/release/bsdtar"

# wget failed: ssl_client: TLS error from peer (alert code 80): 80
curl --location "$download_url" --output "tool-$tool_version.tar.xz"
"$bsdtar" -xf "tool-$tool_version.tar.xz"

echo "::endgroup::"

echo "::group::build"

cd "$dp0/release/CPP/7zip/Bundles/Alone2"
nmake DISABLE_RAR=1
cp -f "./_o/7zz.exe" "$release_version_dirpath/"

echo "::endgroup::"

cd "$release_version_dirpath"

strip 7zz.exe

{ printf '### %s
%s

SHA-256: %s

%s

' "$self_toolset_name.tar.gz" "$(./7zz.exe | head -2)" "$(sha256sum 7zz.exe)" "$download_url"
} > "$self_toolset_name.md"

cat "$self_toolset_name.md"

"$bsdtar" -czvf "../$self_toolset_name.tar.gz" .
