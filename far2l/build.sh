#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

apk update
apk add --no-cache alpine-sdk gawk m4 pcre2-dev libssh-dev libressl-dev libnfs-dev libarchive-dev cmake git
apk add --no-cache uchardet-dev neon-dev spdlog-dev xerces-c-dev

mkdir -p "$dp0/release" && cd "$dp0/release"

# Download release
wget https://github.com/elfmz/far2l/archive/refs/tags/v_2.4.0.tar.gz -O v_2.4.0.tar.gz
tar -xf v_2.4.0.tar.gz && cd far2l-v_2.4.0

cmake -DUSEWX=no -DCMAKE_BUILD_TYPE=Release .
