#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

apk update
apk add --no-cache mingw-w64-gcc zlib-dev bzip2-dev zlib-static bzip2-static

echo "::endgroup::"

ZLIB_VERSION=1.2.11
BZIP2_VERSION=b7a672291188a6469f71dd13ad14f2f9a7344fc8
XZ_VERSION=5.2.5

echo "::group::prepare deps"

mkdir -p "$dp0/build_ci/libs" && cd "$dp0/build_ci/libs"

zlib_download_url="https://github.com/libarchive/zlib/archive/v$ZLIB_VERSION.tar.gz"
echo Downloading "$zlib_download_url"
wget "$zlib_download_url" -O "zlib-$ZLIB_VERSION.tar.gz"
tar -xf "zlib-$ZLIB_VERSION.tar.gz"

bzip_download_url="https://github.com/libarchive/bzip2/archive/$BZIP2_VERSION.tar.gz"
echo Downloading "$bzip_download_url"
wget "$bzip_download_url" -O "bzip-$BZIP2_VERSION.tar.gz"
tar -xf "bzip-$BZIP2_VERSION.tar.gz"

xz_download_url="https://github.com/libarchive/xz/archive/v$XZ_VERSION.tar.gz"
echo Downloading "$xz_download_url"
wget "$xz_download_url" -O "xz-$XZ_VERSION.tar.gz"
tar -xf "xz-$XZ_VERSION.tar.gz"

echo "::endgroup::"

tool_name="bsdtar"
tool_version="3.5.1"
echo "::set-output name=tool_name::$tool_name"
echo "::set-output name=tool_version::$tool_version"

download_url="https://github.com/libarchive/libarchive/releases/download/v3.5.1/libarchive-$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

mkdir -p "$dp0/release" && cd "$dp0/release"
wget "$download_url" -O "libarchive-$tool_version.tar.gz"
tar -xf "libarchive-$tool_version.tar.gz" && cd "libarchive-$tool_version"

echo "::endgroup::"

echo "::group::build"

./configure LDFLAGS='--static' --enable-bsdtar=static --disable-shared --disable-bsdcpio --disable-bsdcat
make -j$(nproc)
gcc -static -o "../$tool_name" \
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
  /usr/lib/libbz2.a

echo "::endgroup::"
