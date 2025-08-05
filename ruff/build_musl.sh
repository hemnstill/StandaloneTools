#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

apk update
apk add --no-cache alpine-sdk musl-dev gcc curl wget rustup pkgconfig openssl-dev

rustup-init -y
. "$HOME/.cargo/env"

echo "::endgroup::"

tool_name="ruff"
tool_name_ty="ty"
tool_version="0.12.7"
self_name="build-$tool_name-$tool_version"
self_toolset_name="build-musl"
release_version_dirpath="$dp0/release/$self_name"

mkdir -p "$release_version_dirpath" && cd "$dp0/release"

download_url="https://github.com/astral-sh/ruff/archive/refs/tags/$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

"$dp0/../.tools/download_bsdtar.sh"
bsdtar="$dp0/release/bsdtar"

wget "$download_url" -O "tool-$tool_version.tar.gz"
"$bsdtar" -xf "tool-$tool_version.tar.gz" && cd "$tool_name-$tool_version"

cargo build --target x86_64-unknown-linux-musl --release

find "./target/x86_64-unknown-linux-musl/release" -maxdepth 1 -type f \( -name "$tool_name" -o -name "$tool_name_ty" \) -exec cp -f {} "$release_version_dirpath/" \;

echo "::endgroup::"

cd "$release_version_dirpath"
strip "$tool_name"
strip "$tool_name_ty"
chmod +x "$tool_name"
chmod +x "$tool_name_ty"

{ printf '%s

### %s
SHA-256: %s
SHA-256: %s

' "$("./$tool_name" --version)" "$self_toolset_name.tar.gz" "$(sha256sum $tool_name)" "$(sha256sum $tool_name_ty)"
} > "$self_toolset_name.md"

cat "$self_toolset_name.md"

tar -czvf "../$self_toolset_name.tar.gz" .
