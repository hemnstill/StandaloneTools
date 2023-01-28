#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

is_rockylinux_os=false && [[ -f "/etc/rockylinux-release" ]] && is_rockylinux_os=true

echo "::group::install deps"

if [[ "$is_rockylinux_os" == true ]]; then
  yum -y install tar
fi


echo "::endgroup::"

tool_name="upx"
tool_version="3.96"
self_name="$tool_name-$tool_version"

download_url="https://github.com/upx/upx/releases/download/v$tool_version/$self_name-amd64_linux.tar.xz"
echo "::group::prepare sources $download_url"

mkdir -p "$dp0/release/build" && cd "$dp0/release"
rm -rf "$dp0/release/build/"*
wget "$download_url" -O "$self_name.tar.xz"
tar -xf "$self_name.tar.xz" && cd "$self_name-amd64_linux"

echo "::endgroup::"

echo "::group::build"

cp ./upx "$dp0/release/build/upx"
./upx -d "$dp0/release/build/upx"

cp ./upx "$dp0/release/build/upx_packed"
# repacking
./upx -d "$dp0/release/build/upx_packed"
./upx -9 "$dp0/release/build/upx_packed"

cp "$dp0/release/bsdtar" "$dp0/release/build/"

echo "::endgroup::"

cd "$dp0/release/build"

{ printf '
%s

SHA-256: %s
%s

' "$("./$tool_name" --version)" "$(sha256sum "./$tool_name")" "$download_url"
} > build-musl.md

cat build-musl.md

tar -czvf ../build-musl.tar.gz .
