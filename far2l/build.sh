#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

apk update
apk add --no-cache alpine-sdk gawk m4 libssh-dev libressl-dev libnfs-dev libarchive-dev cmake g++ git
apk add --no-cache pcre2-dev uchardet-dev neon-dev spdlog-dev xerces-c-dev
apk add --no-cache musl-dev linux-headers

mkdir -p "$dp0/release" && cd "$dp0/release"

# Download release
wget https://github.com/elfmz/far2l/archive/refs/tags/v_2.4.0.tar.gz -O v_2.4.0.tar.gz
tar -xf v_2.4.0.tar.gz && cd far2l-v_2.4.0

cmake -DUSEWX=no -DCMAKE_BUILD_TYPE=Release .

cmake --build .
