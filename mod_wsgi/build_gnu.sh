#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e
export DEBIAN_FRONTEND=noninteractive

echo "::group::install deps"

apt update
apt install -y --no-install-recommends ca-certificates wget apache2-dev clang clang-10

echo "::endgroup::"

tool_name="mod_wsgi"
tool_version="4.9.4"
self_name="$tool_name-$tool_version"
release_version_dirpath="$dp0/release/$self_name"

mkdir -p "$release_version_dirpath/Scripts/bin" && cd "$dp0/release"

echo "download poetry install script ..."
poetry_bin_download_url="https://github.com/hemnstill/StandaloneTools/releases/download/poetry-1.5.1/build-gnu.tar.gz"
poetry_download_zip="$dp0/release/poetry.tar.gz"
[[ ! -f "$poetry_download_zip" ]] && wget "$poetry_bin_download_url" -O "$poetry_download_zip" --no-verbose

"$dp0/../.tools/download_bsdtar.sh"
bsdtar="$dp0/release/bsdtar"

cpython_bin="$release_version_dirpath/Scripts/bin/python3"
cpython_lib="$release_version_dirpath/Scripts/lib"
[[ ! -f "$cpython_bin" ]] && "$bsdtar" -xf "$poetry_download_zip" -C "$release_version_dirpath"

cp -v "$cpython_lib/libpython3.11.so" /usr/lib/
cp -v "$cpython_lib/libpython3.11.so.1.0" /usr/lib/

"$cpython_bin" -m pip wheel "$tool_name==$tool_version" --wheel-dir "$release_version_dirpath"

echo "creating archive ..."

cd "$release_version_dirpath"

"$bsdtar" \
  --exclude="__pycache__" \
  --exclude="Scripts" \
  -czvf ../build-gnu.tar.gz .
