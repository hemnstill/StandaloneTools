#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

choco install mingw

echo "::endgroup::"

tool_name="bsdtar.exe"
tool_version="3.8.11"
self_toolset_name="build-mingw"

download_url="https://github.com/libarchive/libarchive/releases/download/v$tool_version/libarchive-$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

mkdir -p "$dp0/release" && cd "$dp0/release"
wget "$download_url" -O "libarchive-$tool_version.tar.gz"
tar -xf "libarchive-$tool_version.tar.gz" && cd "libarchive-$tool_version"

ci_download_url="https://raw.githubusercontent.com/libarchive/libarchive/v$tool_version/build/ci/github_actions/ci.cmd"
wget "$ci_download_url" -O "$dp0/ci.cmd"

# Upstream ci.cmd expects MSYS2 packages (bzip2 included) and links them dynamically.
# The patch switches it to the choco mingw toolchain, disables bzip2
# and links the static zlib/xz/zstd built below.
patch "$dp0/ci.cmd" "$dp0/release/bdstar_remove_bzip2.diff"

echo "::endgroup::"

# Same PATH as MINGWPATH in ci.cmd: keeps sh.exe out of the way of "MinGW Makefiles".
mingw_path="C:/WINDOWS/system32;C:/WINDOWS;C:/ProgramData/mingw64/mingw64/bin;C:/Program Files/cmake/bin"
export DEPS="$dp0/release/deps"

build_static_dep() (
  name="$1"
  url="$2"
  source_dir="$3"

  echo "::group::build $name $url"
  cd "$dp0/release"
  wget "$url" -O "$name.zip"
  unzip -q -o "$name.zip"
  cd "$source_dir"
  export PATH="$mingw_path"
  cmake -G "MinGW Makefiles" -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX="$DEPS" -S . -B _build
  cmake --build _build -j "$NUMBER_OF_PROCESSORS"
  cmake --install _build
  echo "::endgroup::"
)

build_static_dep zlib-1.3 "https://github.com/libarchive/zlib/archive/v1.3.zip" "zlib-1.3"
build_static_dep xz-5.6.3 "https://github.com/libarchive/xz/archive/v5.6.3.zip" "xz-5.6.3"
build_static_dep zstd-1.5.7 "https://github.com/facebook/zstd/archive/refs/tags/v1.5.7.zip" "zstd-1.5.7/build/cmake"

echo "::group::build"

export BE=mingw

"$dp0/ci.cmd" configure
"$dp0/ci.cmd" build

echo "::endgroup::"

mkdir "$dp0/release/build" && cd "$dp0/release/build"
cp -f "$dp0/release/libarchive-$tool_version/build_ci/cmake/bin/$tool_name" "."

{ printf '### %s
SHA-256: %s
%s
%s
' "$self_toolset_name.tar.gz" "$(sha256sum $tool_name)" "$("./$tool_name" --version)" "$download_url"
} > "$self_toolset_name.md"

cat "$self_toolset_name.md"

tar -czvf "../$self_toolset_name.tar.gz" .
