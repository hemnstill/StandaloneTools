#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
cd "$dp0" || exit 1

set -e

# Install build dependencies
apk update
apk add --no-cache alpine-sdk util-linux strace file zlib-dev autoconf automake libtool zlib-dev bzip2-dev

wget https://www.libarchive.org/downloads/libarchive-3.3.2.tar.gz
tar xf libarchive-3.3.2.tar.gz
cd libarchive-3.3.2
./configure LDFLAGS='--static' --enable-bsdtar=static --disable-shared --with-zlib --without-bz2lib --disable-bsdcpio --disable-bsdcat
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
