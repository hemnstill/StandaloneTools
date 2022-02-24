#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

apk update
apk add --no-cache gawk m4 libssh-dev libressl-dev libnfs-dev libarchive-dev cmake alpine-sdk linux-headers git
apk add --no-cache pcre2-dev uchardet-dev neon-dev spdlog-dev xerces-c-dev
apk add --no-cache libexecinfo-dev

mkdir -p "$dp0/release" && cd "$dp0/release"

# Download release
wget https://github.com/elfmz/far2l/archive/refs/tags/v_2.4.0.tar.gz -O v_2.4.0.tar.gz
tar -xf v_2.4.0.tar.gz && cd far2l-v_2.4.0

cp -f "../SafeMMap.cpp" "./far2l/src/base/"

cmake -DUSEWX=no -DCMAKE_EXE_LINKER_FLAGS="-static-libgcc -static-libstdc++" -DCMAKE_BUILD_TYPE=Release .

cmake --build . --config Release

cp -rf "$dp0/release/far2l-v_2.4.0/install/." "$dp0/release/build/"

cd "$dp0/release/build"
chmod +x "far2l"
ldd "far2l"
"./far2l" --help
