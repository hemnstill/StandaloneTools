#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

apk update
apk add --no-cache alpine-sdk python3-dev

tool_name="poetry"
tool_version="1.3.1"
python_self_name="python-3.10.9"
self_name="$tool_name-$tool_version"
release_version_dirpath="$dp0/release/$self_name"
echo "::set-output name=tool_name::$tool_name"
echo "::set-output name=tool_version::$tool_version"

mkdir -p "$release_version_dirpath" && cd "$dp0/release"

echo "download python install script ..."
python_bin_download_url="https://github.com/hemnstill/StandaloneTools/releases/download/$python_self_name/build-musl.tar.gz"
python_download_zip="$dp0/release/$python_self_name.tar.gz"
[[ ! -f "$python_download_zip" ]] && wget "$python_bin_download_url" -O "$python_download_zip"

echo "download bsdtar ..."
bsdtar_version=3.6.2
bsdtar_download_url="https://github.com/hemnstill/StandaloneTools/releases/download/bsdtar-$bsdtar_version/build-musl.tar.gz"
bsdtar_tar_gz="bsdtar-$bsdtar_version-build-musl.tar.gz"
[[ ! -f "$bsdtar_tar_gz" ]] && wget "$bsdtar_download_url" -O "$bsdtar_tar_gz"
tar -xf "$bsdtar_tar_gz"

bsdtar="$dp0/release/bsdtar"
cpython_bin="$release_version_dirpath/Scripts/bin/python3"
[[ ! -f "$cpython_bin" ]] && tar -xf "$python_download_zip" -C "$release_version_dirpath"

echo "install poetry ..."
cpython_lib_path="$release_version_dirpath/Scripts/lib/python3.10/site-packages"

installed_python_version="$("python3" --version)"
standalone_python_version="$("$cpython_bin" --version)"
echo "$installed_python_version (alpine)"
echo "$standalone_python_version (standalone)"
if [[ "$installed_python_version" != "$standalone_python_version" ]]; then
  echo "required same python versions."
  exit 1
fi;

"python3" -m ensurepip
"python3" -m pip install --target="$cpython_lib_path" "poetry==$tool_version"

"$cpython_bin" -m pip install "poetry==$tool_version"

echo "prepare build artifacts ..."

cp -f "$dp0/release/poetry.sh" "$release_version_dirpath/"
cp -f "$dp0/release/__main__poetry.py" "$release_version_dirpath/"

echo "creating archive ..."

cd "$release_version_dirpath"
{ printf '%s

Python %s

' "$(./"$tool_name.sh" about)" "$("$cpython_bin" -c "import sys; print(sys.version)")"
} > build-musl.md

cat build-musl.md

"$bsdtar" \
  --exclude="__pycache__" \
  --exclude="Scripts/Scripts" \
  --exclude="*.whl" \
  -czvf ../build-musl.tar.gz .
