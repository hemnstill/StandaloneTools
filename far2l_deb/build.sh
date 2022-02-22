#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e
export DEBIAN_FRONTEND=noninteractive
apt update
apt install -y libspdlog-dev patchelf wget gawk m4 libx11-dev libxi-dev libxerces-c-dev libuchardet-dev libssh-dev libssl-dev libnfs-dev libneon27-dev libarchive-dev libpcre3-dev cmake g++ git

mkdir -p "$dp0/release" && cd "$dp0/release"

# Download release
wget https://github.com/elfmz/far2l/archive/refs/tags/v_2.4.0.tar.gz -O v_2.4.0.tar.gz
tar -xf v_2.4.0.tar.gz && cd far2l-v_2.4.0

cmake -DUSEWX=no -DNETROCKS=no -DUSEUCD=no -DCOLORER=no -DMULTIARC=no -DCMAKE_BUILD_TYPE=Release .

cmake --build . --config Release

cp -rf "$dp0/release/far2l-v_2.4.0/install/." "$dp0/release/build/"

cd "$dp0/release/build"
strip "far2l"
chmod +x "far2l"
ldd "far2l"
"./far2l" --help
