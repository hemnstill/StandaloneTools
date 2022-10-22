#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

apk update
apk add --no-cache alpine-sdk make linux-headers build-base musl-dev clang libressl-dev libffi-dev python3-dev ncurses-dev cargo

tool_name="poetry"
tool_version="1.2.2"
self_name="$tool_name-$tool_version"
release_version_dirpath="$dp0/release/$self_name"
echo "::set-output name=tool_name::$tool_name"
echo "::set-output name=tool_version::$tool_version"

mkdir -p "$release_version_dirpath" && cd "$dp0/release"

echo "download python ..."
download_url="https://github.com/indygreg/python-build-standalone/releases/download/20220630/cpython-3.10.5+20220630-x86_64-unknown-linux-musl-noopt-full.tar.zst"
cpython_zip="$dp0/release/raw_cpython-linux.tar.zst"
[[ ! -f "$cpython_zip" ]] && wget "$download_url" -O "$cpython_zip"

echo "download bsdtar ..."
bsdtar_download_url="https://github.com/hemnstill/StandaloneTools/releases/download/bsdtar-3.6.1/build-musl.tar.gz"
bsdtar_tar_gz="bsdtar-3.6.1_build-musl.tar.gz"
[[ ! -f "$bsdtar_tar_gz" ]] && wget "$bsdtar_download_url" -O "$bsdtar_tar_gz"
tar -xf "$bsdtar_tar_gz"

bsdtar="$dp0/release/bsdtar"
cpython_bin="$dp0/.tmp/python/install/bin/python3"
cpython_site_packages="$dp0/.tmp/python/install/lib/python3.10/site-packages"
if [[ ! -f "$cpython_bin" ]]; then
  echo extract "$cpython_zip" to "$cpython_bin" ...
  rm -rf "$dp0/.tmp/"* && mkdir -p "$dp0/.tmp" && cd "$dp0/.tmp" || exit 1

  "$bsdtar" \
  --exclude="__pycache__" \
  --exclude="test" \
  --exclude="tests" \
  --exclude="idle_test" \
  --exclude="venv" \
  --exclude="Scripts" \
  --exclude="*.pdb" \
  --exclude="*.pickle" \
  --exclude="tcl*.dll" \
  --exclude="lib/tcl*" \
  --exclude="tk*.dll" \
  --exclude="lib/tk*" \
  --exclude="python/install/tcl" \
  -xf "$cpython_zip" python/install
fi;

echo "install poetry ..."
export POETRY_HOME="$dp0/.tmp/poetry"
echo "$($cpython_bin --version) (alpine)"
"python3" -m ensurepip
"python3" -m pip install cffi

cp -rf "/usr/lib/python3.10/site-packages" "$cpython_site_packages"

echo "$($cpython_bin --version) (standalone)"
"$cpython_bin" -m pip install poetry=="$tool_version"

echo "prepare build artifacts ..."
rm -rf "$dp0/release/$self_name" && mkdir -p "$dp0/release/$self_name"
python_scripts_path="$dp0/release/$self_name/Scripts"
cp -rf "$dp0/.tmp/python/install" "$python_scripts_path/"
cp -f "$dp0/release/poetry.sh" "$dp0/release/$self_name/"
cp -f "$dp0/release/__main__.py" "$dp0/release/$self_name/"

echo "creating archive ..."

cd "$release_version_dirpath"
{ printf '%s
' "$("$cpython_bin" --version)"
} > build-musl.md

cat build-musl.md

"$bsdtar" \
  --exclude="__pycache__" \
  --exclude="Scripts/Scripts" \
  --exclude="*.whl" \
  -czvf ../build-musl.tar.gz .
