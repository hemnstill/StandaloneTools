#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

apk update
apk add --no-cache gawk m4 libssh-dev libressl-dev libnfs-dev libarchive-dev cmake alpine-sdk linux-headers musl-dev git
apk add --no-cache uchardet-dev  neon-dev spdlog-dev xerces-c-dev libexecinfo-dev
apk add --no-cache uchardet-static libexecinfo-static

echo "::endgroup::"

tool_name="far2l"
tool_version="2.4.0"
echo "::set-output name=tool_name::$tool_name"
echo "::set-output name=tool_version::$tool_version"

download_url="https://github.com/elfmz/far2l/archive/refs/tags/v_$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

# Download release
mkdir -p "$dp0/release" && cd "$dp0/release"
wget "$download_url" -O "v_$tool_version.tar.gz"
tar -xf "v_$tool_version.tar.gz" && cd "far2l-v_$tool_version"

cp -f "../SafeMMap.cpp" "./far2l/src/base/"
cp -f "../sort_r.h" "./far2l/src/base/"
cp -f "../farrtl.cpp" "./far2l/src/base/"

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

cp -rf "$dp0/release/far2l-v_$tool_version/install/." "$dp0/release/build/"

cd "$dp0/release/build"
strip "$tool_name"
chmod +x "$tool_name"

tar -cvf ../far2l.tar .

{ printf 'ldd: %s
SHA-256: %s
%s
%s' "$(ldd $tool_name)" "$(sha256sum < $tool_name)" "$("./$tool_name" --help | head -n1)" "$download_url"
} > body.md

cat body.md
