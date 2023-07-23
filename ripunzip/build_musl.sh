#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

apk update
apk add --no-cache alpine-sdk musl-dev gcc curl wget rustup pkgconfig openssl-dev

rustup-init -y

. "$HOME/.cargo/env"

echo "::endgroup::"

tool_name="ripunzip"
tool_version="0.1.0"
self_name="$tool_name-$tool_version"
release_version_dirpath="$dp0/release/$self_name"

mkdir -p "$release_version_dirpath" && cd "$dp0/release"

download_url="https://github.com/google/ripunzip/archive/refs/heads/main.tar.gz"
echo "::group::prepare sources $download_url"

"$dp0/../.tools/download_bsdtar.sh"
bsdtar="$dp0/release/bsdtar"

wget "$download_url" -O "tool-$tool_version.tar.gz"
"$bsdtar" -xf "tool-$tool_version.tar.gz" && cd "$tool_name-main"

cargo build

cp -f "./target/debug/$tool_name" "$release_version_dirpath/"

echo "::endgroup::"

cd "$release_version_dirpath"
strip "$tool_name"
chmod +x "$tool_name"

{ printf '### %s
%s
SHA-256: %s

' "$self_toolset_name.tar.gz" "$(sha256sum $tool_name)" "$("./$tool_name" --version)"
} > "$self_toolset_name.md"

cat "$self_toolset_name.md"

tar -czvf "../$self_toolset_name.tar.gz" .
