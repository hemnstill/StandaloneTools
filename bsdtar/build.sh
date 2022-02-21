#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

apk update
apk add --no-cache alpine-sdk zlib-dev bzip2-dev zlib-static

mkdir -p "$dp0/release" && cd "$dp0/release"

# Download release
wget https://github.com/libarchive/libarchive/releases/download/v3.5.1/libarchive-3.5.1.tar.gz -O libarchive-3.5.1.tar.gz
tar -xf libarchive-3.5.1.tar.gz && cd libarchive-3.5.1

./configure LDFLAGS='--static' --enable-bsdtar=static --disable-shared --disable-bsdcpio --disable-bsdcat
make -j$(nproc)
gcc -static -o ../bsdtar \
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

cd "$dp0/release"
strip "bsdtar"
chmod +x "bsdtar"
"./bsdtar" --version
