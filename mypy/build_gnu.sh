#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

apt update
apt install -y wget binutils

tool_name="mypy"
tool_version="1.4.1"
self_name="python-3.11.3"
self_toolset_name="build-gnu"

release_version_dirpath="$dp0/release/$tool_name-$tool_version"
mkdir -p "$release_version_dirpath" && cd "$dp0/release"

echo "download python install script ..."
python_bin_download_url="https://github.com/hemnstill/StandaloneTools/releases/download/$self_name/$self_toolset_name.tar.gz"
python_download_zip="$dp0/release/$self_name.tar.gz"
[[ ! -f "$python_download_zip" ]] && wget "$python_bin_download_url" -O "$python_download_zip"

"$dp0/../.tools/download_bsdtar.sh"
bsdtar="$dp0/release/bsdtar"

cpython_bin="$release_version_dirpath/Scripts/bin/python3"
[[ ! -f "$cpython_bin" ]] && tar -xf "$python_download_zip" -C "$release_version_dirpath"

"$cpython_bin" -m pip install "$tool_name==$tool_version"

cp -f "$dp0/release/$tool_name.sh" "$release_version_dirpath/"
cp -f "$dp0/release/__main__$tool_name.py" "$release_version_dirpath/"

find "$release_version_dirpath/Scripts/lib/python3.11/site-packages/" \
  -mindepth 1 -maxdepth 1 -name '*-linux-gnu.so' \
  -exec echo strip "{}" \; -exec strip "{}" \;

echo "creating archive ..."

cd "$release_version_dirpath"
{ printf '### %s
%s
Python %s
' "$self_toolset_name.tar.gz" "$(./"$tool_name.sh" --version)" "$("$cpython_bin" -c "import sys; print(sys.version)")"
} > $self_toolset_name.md

cat $self_toolset_name.md

"$bsdtar" \
  --exclude="__pycache__" \
  --exclude="Scripts/Scripts" \
  --exclude="*.whl" \
  -czvf ../$self_toolset_name.tar.gz .

