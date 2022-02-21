#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

apk update
apk add --no-cache alpine-sdk pcre2-dev

mkdir -p "$dp0/release" && cd "$dp0/release"

# Download release
wget https://github.com/elfmz/far2l/archive/refs/tags/v_2.4.0.tar.gz -O v_2.4.0.tar.gz
tar -xf v_2.4.0.tar.gz && cd far2l-v_2.4.0

#./configure LDFLAGS='--static' --disable-shared --enable-jit --enable-pcre2-8 --enable-pcre2-16 --enable-pcre2-32
#
#make -j$(nproc)
#
#cp -f "$dp0/release/pcre2-10.39/pcre2grep" "$dp0/release/"
#
#cd "$dp0/release"
#strip "pcre2grep"
#chmod +x "pcre2grep"
#"./pcre2grep" --version
