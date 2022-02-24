#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e
export DEBIAN_FRONTEND=noninteractive

echo "::group::install deps"

apt update
apt install -y build-essential libspdlog-dev patchelf wget gawk m4 libx11-dev libxi-dev libxerces-c-dev libuchardet-dev libssh-dev libssl-dev libnfs-dev libneon27-dev libarchive-dev libpcre3-dev cmake git

echo "::endgroup::"

echo "::group::prepare sources v_2.4.0"

mkdir -p "$dp0/release" && cd "$dp0/release"

# Download release
wget https://github.com/elfmz/far2l/archive/refs/tags/v_2.4.0.tar.gz -O v_2.4.0.tar.gz
tar -xf v_2.4.0.tar.gz && cd far2l-v_2.4.0

echo "::endgroup::"

echo "::group::build"

without_plugins="\
-DALIGN=no \
-DAUTOWRAP=no \
-DCALC=no \
-DCOLORER=no \
-DCOMPARE=no \
-DDRAWLINE=no \
-DEDITCASE=no \
-DEDITORCOMP=no \
-DFARFTP=no \
-DFILECASE=no \
-DINCSRCH=no \
-DINSIDE=no \
-DMULTIARC=no \
-DNETROCKS=no \
-DSIMPLEINDENT=no \
-DTMPPANEL=no \
"

cmake_command=$(printf 'cmake -DUSEWX=no -DUSEUCD=no %s -DCMAKE_EXE_LINKER_FLAGS="%s" -DCMAKE_BUILD_TYPE=Release .' \
"$without_plugins" \
"-l:libuchardet.a -static-libstdc++ -static-libgcc")
echo ">> $cmake_command"
eval "$cmake_command"

cmake --build . --config Release

echo "::endgroup::"

cp -rf "$dp0/release/far2l-v_2.4.0/install/." "$dp0/release/build/"

cd "$dp0/release/build"
chmod +x "far2l"
ldd "far2l"
"./far2l" --help | head -n 1
