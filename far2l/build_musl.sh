#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

apk update
apk add --no-cache \
  gawk \
  m4 \
  libssh-dev \
  libressl-dev \
  libnfs-dev \
  libarchive-dev \
  cmake \
  alpine-sdk \
  linux-headers \
  musl-dev \
  git \
  uchardet-dev  \
  neon-dev \
  spdlog-dev \
  xerces-c-dev \
  libexecinfo-dev \
  uchardet-static \
  libexecinfo-static

echo "::endgroup::"

tool_name="far2l"
tool_version="2.5.0"
self_name="$tool_name-$tool_version"
self_toolset_name="build-musl"
self_url="https://github.com/hemnstill/StandaloneTools/releases/download/$self_name/$self_toolset_name.tar.gz"

download_url="https://github.com/elfmz/far2l/archive/v_$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

# Download release
mkdir -p "$dp0/release/build" && cd "$dp0/release"
wget "$download_url" -O "$tool_version.tar.gz"
tar -xf "$tool_version.tar.gz" && cd "far2l-v_$tool_version"

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

cp -rf "$dp0/release/far2l-v_$tool_version/install/." "$dp0/release/build/"

cd "$dp0/release/build"
strip "$tool_name"
chmod +x "$tool_name"

{ printf '### %s (without plugins)
`wget -qO- %s | tar -xz`

SHA-256: %s
%s

<details>
  <summary>ldd far2l</summary>

```
%s
```
</details>

%s

' "$self_toolset_name.tar.gz" \
  "$self_url" \
  "$(sha256sum < $tool_name)" \
  "$("./$tool_name" --help | head -n2)" \
  "$(ldd $tool_name)" \
  "$download_url"
} > "$self_toolset_name.md"

cat "$self_toolset_name.md"

tar -czvf "../$self_toolset_name.tar.gz" .
