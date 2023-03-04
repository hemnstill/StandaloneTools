#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e
export DEBIAN_FRONTEND=noninteractive

echo "::group::install deps"

apt update
apt install -y \
  build-essential \
  libspdlog-dev \
  patchelf \
  wget \
  gawk \
  m4 \
  libx11-dev \
  libxi-dev \
  libxerces-c-dev \
  libuchardet-dev \
  libssl-dev \
  libnfs-dev \
  libneon27-dev \
  libarchive-dev \
  libpcre3-dev \
  libsmbclient-dev \
  libfmt-dev \
  libssh-dev \
  cmake git

echo "::endgroup::"

tool_name="far2l"
tool_version="2.5.0"
self_name="$tool_name-$tool_version"
self_toolset_name="build-glibc-p"
self_url="https://github.com/hemnstill/StandaloneTools/releases/download/$self_name/$self_toolset_name.tar.gz"

echo "::set-output name=tool_name::$tool_name"
echo "::set-output name=tool_version::$tool_version"

download_url="https://github.com/elfmz/far2l/archive/v_$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

# Download release
mkdir -p "$dp0/release/build" && cd "$dp0/release"
wget "$download_url" -O "$tool_version.tar.gz"
tar -xf "$tool_version.tar.gz" && cd "far2l-v_$tool_version"

echo "::endgroup::"

echo "::group::build"

cmake_command=$(printf 'cmake -DCMAKE_CXX_FLAGS="-DXERCES_STATIC_LIBRARY" -DUSEWX=no -DUSEUCD=no -DCMAKE_EXE_LINKER_FLAGS="%s" -DCMAKE_BUILD_TYPE=Release .' \
  "-l:libuchardet.a -l:libxerces-c.a -static-libstdc++ -static-libgcc")
echo ">> $cmake_command"
eval "$cmake_command"

cmake --build . --config Release

echo "::endgroup::"

cp -rf "$dp0/release/far2l-v_$tool_version/install/." "$dp0/release/build/"

cd "$dp0/release/build"
strip "$tool_name"
chmod +x "$tool_name"

{ printf '### %s
`wget -qO- %s | tar -xz`
ldd: %s
SHA-256: %s
%s
%s

' "$self_toolset_name.tar.gz" "$self_url" "$(ldd $tool_name)" "$(sha256sum < $tool_name)" "$("./$tool_name" --help | head -n2)" "$download_url"
} > "$self_toolset_name.md"

cat "$self_toolset_name.md"

tar -czvf "../$self_toolset_name.tar.gz" .
