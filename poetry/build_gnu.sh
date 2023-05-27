#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

apt update
apt install -y wget binutils

tool_name="poetry"
tool_version="1.5.0"
python_self_name="python-3.11.3"
python_release_date="20230507"
self_name="$tool_name-$tool_version"
self_toolset_name="build-gnu"
release_version_dirpath="$dp0/release/$self_name"
echo "::set-output name=tool_name::$tool_name"
echo "::set-output name=tool_version::$tool_version"

mkdir -p "$release_version_dirpath" && cd "$dp0/release"

echo "download python install script ..."
python_bin_download_url="https://github.com/hemnstill/StandaloneTools/releases/download/$python_self_name/$self_toolset_name.tar.gz"
python_download_zip="$dp0/release/$python_self_name.tar.gz"
[[ ! -f "$python_download_zip" ]] && wget "$python_bin_download_url" -O "$python_download_zip"

python_include_download_url="https://github.com/indygreg/python-build-standalone/releases/download/$python_release_date/c$python_self_name+$python_release_date-x86_64-unknown-linux-gnu-pgo-full.tar.zst"
python_include_download_zip="$dp0/release/$python_self_name.tar.zst"
[[ ! -f "$python_include_download_zip" ]] && wget "$python_include_download_url" -O "$python_include_download_zip"

"$dp0/../.tools/download_bsdtar.sh"
bsdtar="$dp0/release/bsdtar"

cpython_bin="$release_version_dirpath/Scripts/bin/python3"
[[ ! -f "$cpython_bin" ]] && tar -xf "$python_download_zip" -C "$release_version_dirpath"

"$bsdtar" -xf "$python_include_download_zip" "python/install/include"
cp -rf "python/install/include" "$release_version_dirpath/Scripts/include/"

echo "install poetry ..."
"$cpython_bin" -m pip install "poetry==$tool_version"

echo "prepare build artifacts ..."

cp -f "$dp0/release/poetry.sh" "$release_version_dirpath/"
cp -f "$dp0/release/__main__poetry.py" "$release_version_dirpath/"

echo "creating archive ..."

cd "$release_version_dirpath"
{ printf '### %s
%s
Python %s

' "$self_toolset_name.tar.gz" "$(./"$tool_name.sh" about)" "$("$cpython_bin" -c "import sys; print(sys.version)")"
} > $self_toolset_name.md

cat $self_toolset_name.md

"$bsdtar" \
  --exclude="__pycache__" \
  --exclude="Scripts/Scripts" \
  -czvf ../$self_toolset_name.tar.gz .
