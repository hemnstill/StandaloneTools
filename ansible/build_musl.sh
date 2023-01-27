#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

apk update
apk add --no-cache alpine-sdk python3-dev gcompat

tool_name="ansible"
tool_version="7.1.0"
python_self_name="python-3.10.9"
self_name="$tool_name-$tool_version"
release_version_dirpath="$dp0/release/$self_name"
echo "::set-output name=tool_name::$tool_name"
echo "::set-output name=tool_version::$tool_version"

mkdir -p "$release_version_dirpath" && cd "$dp0/release"

echo "download python install script ..."
python_bin_download_url="https://github.com/indygreg/python-build-standalone/releases/download/20221220/cpython-3.10.9+20221220-x86_64-unknown-linux-gnu-pgo-full.tar.zst"
python_download_zip="$dp0/release/$python_self_name.tar.gz"
[[ ! -f "$python_download_zip" ]] && wget "$python_bin_download_url" -O "$python_download_zip"

echo "download bsdtar ..."
bsdtar_version=3.6.2
bsdtar_download_url="https://github.com/hemnstill/StandaloneTools/releases/download/bsdtar-$bsdtar_version/build-musl.tar.gz"
bsdtar_tar_gz="bsdtar-$bsdtar_version-build-musl.tar.gz"
[[ ! -f "$bsdtar_tar_gz" ]] && wget "$bsdtar_download_url" -O "$bsdtar_tar_gz"
tar -xf "$bsdtar_tar_gz"

bsdtar="$dp0/release/bsdtar"
cpython_bin="$release_version_dirpath/python/install/bin/python3"
cpython_lib_path="$release_version_dirpath/python/install/lib/python3.10/site-packages"
[[ ! -f "$cpython_bin" ]] && "$bsdtar" -xf "$python_download_zip" -C "$release_version_dirpath"

echo "install ansbile ..."

export CFLAGS="-Dffi_call=cffistatic_ffi_call"
"python3" -m ensurepip
"python3" -m pip install --target="$cpython_lib_path" cffi

"$cpython_bin" -m pip install "$tool_name==$tool_version"

echo "prepare build artifacts ..."

cp -f "$dp0/release/ansible.sh" "$release_version_dirpath/"
cp -f "$dp0/release/__main__ansible.py" "$release_version_dirpath/"

echo "creating archive ..."

cd "$release_version_dirpath"
{ printf '%s

Python %s

' "$(./"$tool_name.sh" --version)" "$("$cpython_bin" -c "import sys; print(sys.version)")"
} > build-musl.md

cat build-musl.md

"$bsdtar" \
  --exclude="__pycache__" \
  --exclude="Scripts/Scripts" \
  --exclude="*.whl" \
  -czvf ../build-musl.tar.gz .
