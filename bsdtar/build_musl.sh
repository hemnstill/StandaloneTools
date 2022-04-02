#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

apk update
apk add --no-cache alpine-sdk zlib-dev zlib-static xz-dev zstd-dev zstd-static

echo "::endgroup::"

tool_name="bsdtar"
tool_version="3.6.0"
echo "::set-output name=tool_name::$tool_name"
echo "::set-output name=tool_version::$tool_version"

download_url="https://github.com/libarchive/libarchive/releases/download/v$tool_version/libarchive-$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

mkdir -p "$dp0/release" && cd "$dp0/release"
wget "$download_url" -O "libarchive-$tool_version.tar.gz"
tar -xf "libarchive-$tool_version.tar.gz" && cd "libarchive-$tool_version"

echo "::endgroup::"

echo "::group::build"

./configure LDFLAGS='--static' --enable-bsdtar=static --disable-shared --disable-bsdcpio --disable-bsdcat
make -j$(nproc)

mkdir "$dp0/release/build"
gcc -static -o "$dp0/release/build/$tool_name" \
  tar/bsdtar-bsdtar.o \
  tar/bsdtar-cmdline.o \
  tar/bsdtar-creation_set.o \
  tar/bsdtar-read.o \
  tar/bsdtar-subst.o \
  tar/bsdtar-util.o \
  tar/bsdtar-write.o \
  .libs/libarchive.a \
  .libs/libarchive_fe.a \
  /lib/libz.a \
  /usr/lib/liblzma.a \
  /usr/lib/libzstd.a

echo "::endgroup::"

cd "$dp0/release/build"
strip "$tool_name"
chmod +x "$tool_name"

{ printf 'SHA-256: %s
%s
' "$(sha256sum $tool_name)" "$("./$tool_name" --version)"
} > _musl.md

cat _musl.md

tar -czvf ../build-musl.tar.gz .
