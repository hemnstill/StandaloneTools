#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
mkdir -p "$dp0/release" && cd "$dp0/release" || exit 1

set -e

# Install build dependencies
apk update
apk add --no-cache alpine-sdk util-linux strace file zlib-dev bzip2-dev autoconf automake libtool zlib-static

wget https://github.com/libarchive/libarchive/releases/download/v3.5.1/libarchive-3.5.1.tar.gz -O libarchive-3.5.1.tar.gz
tar -xf libarchive-3.5.1.tar.gz && cd libarchive-3.5.1

./configure LDFLAGS='--static' --enable-bsdtar=static --disable-shared --with-zlib --without-bz2lib
make -j$(nproc)
gcc -static -o bsdtar \
  tar/bsdtar-bsdtar.o \
  tar/bsdtar-cmdline.o \
  tar/bsdtar-creation_set.o \
  tar/bsdtar-read.o \
  tar/bsdtar-subst.o \
  tar/bsdtar-util.o \
  tar/bsdtar-write.o \
  .libs/libarchive.a \
  .libs/libarchive_fe.a \
  /lib/libz.a
