#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

apk update
apk add --no-cache alpine-sdk musl-dev gcc curl wget rustup pkgconfig openssl-dev mingw-w64-gcc

rustup-init -y
. "$HOME/.cargo/env"

echo "::endgroup::"

tool_name="ruff"
tool_version="0.0.280"
self_name="build-$tool_name-$tool_version"
self_toolset_name="build-mingw"
release_version_dirpath="$dp0/release/$self_name"

mkdir -p "$release_version_dirpath" && cd "$dp0/release"

download_url="https://github.com/astral-sh/ruff/archive/refs/tags/v$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

"$dp0/../.tools/download_bsdtar.sh"
bsdtar="$dp0/release/bsdtar"

wget "$download_url" -O "tool-$tool_version.tar.gz"
"$bsdtar" -xf "tool-$tool_version.tar.gz" && cd "$tool_name-$tool_version"

cargo fetch
rustup target add x86_64-pc-windows-msvc
cargo build --target x86_64-pc-windows-msvc --release

cp -f "./target/x86_64-pc-windows-msvc/release/$tool_name.exe" "$release_version_dirpath/"

echo "::endgroup::"

cd "$release_version_dirpath"

strip "$tool_name.exe"

{ printf '### %s
SHA-256: %s

' "$self_toolset_name.tar.gz" "$(sha256sum $tool_name.exe)"
} > "$self_toolset_name.md"

cat "$self_toolset_name.md"

tar -czvf "../$self_toolset_name.tar.gz" .
