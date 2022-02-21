#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

apk update
apk add --no-cache alpine-sdk gawk m4 libssh-dev libressl-dev libnfs-dev libarchive-dev cmake g++ git
apk add --no-cache pcre2-dev uchardet-dev neon-dev spdlog-dev xerces-c-dev
apk add --no-cache musl-dev linux-headers

wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.34-r0/glibc-2.34-r0.apk
apk add --no-cache glibc-2.34-r0.apk

mkdir -p "$dp0/release" && cd "$dp0/release"

# Download release
wget https://github.com/elfmz/far2l/archive/refs/tags/v_2.4.0.tar.gz -O v_2.4.0.tar.gz
tar -xf v_2.4.0.tar.gz && cd far2l-v_2.4.0

export SUPPORTS_BACKTRACE=0
export LD_PRELOAD=/usr/lib/libexecinfo.so

cmake -DUSEWX=no -DCMAKE_BUILD_TYPE=Release -DSTACK_TRACE:BOOL=OFF .

cmake --build . --config Release
