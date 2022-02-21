#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

apk update
apk add --no-cache alpine-sdk zlib-dev bzip2-dev zlib-static bzip2-static

mkdir -p "$dp0/release" && cd "$dp0/release"

# Download release
wget https://github.com/PhilipHazel/pcre2/releases/download/pcre2-10.39/pcre2-10.39.tar.gz -O pcre2-10.39.tar.gz
tar -xf pcre2-10.39.tar.gz && cd pcre2-10.39

./configure LDFLAGS='--static' --enable-bsdtar=static --disable-shared --disable-bsdcpio --disable-bsdcat
