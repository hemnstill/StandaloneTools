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
tool_version="2.5.0"
echo "::set-output name=tool_name::$tool_name"
echo "::set-output name=tool_version::$tool_version"

download_url="https://github.com/elfmz/far2l/archive/$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

# Download release
mkdir -p "$dp0/release/build" && cd "$dp0/release"
wget "$download_url" -O "$tool_version.tar.gz"
tar -xf "$tool_version.tar.gz" && cd "far2l-$tool_version"

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

cmake_command=$(printf 'cmake -DCMAKE_CXX_FLAGS="-D__MUSL__" -DUSEWX=no -DUSEUCD=no %s -DCMAKE_EXE_LINKER_FLAGS="%s" -DCMAKE_BUILD_TYPE=Release .' \
  "$without_plugins" \
  "-l:libuchardet.a -static-libstdc++ -static-libgcc")
echo ">> $cmake_command"
eval "$cmake_command"

cmake --build . --config Release

echo "::endgroup::"

cp -rf "$dp0/release/far2l-$tool_version/install/." "$dp0/release/build/"

cd "$dp0/release/build"
strip "$tool_name"
chmod +x "$tool_name"

{ printf '### build-musl.tar.gz
(without plugins)

ldd: %s
SHA-256: %s
%s
' "$(ldd $tool_name)" "$(sha256sum < $tool_name)" "$("./$tool_name" --help | head -n2)"
} > build-musl.md

cat build-musl.md

tar -czvf ../build-musl.tar.gz .
