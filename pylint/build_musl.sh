#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

tool_name="pylint"
tool_version="2.16.4"
self_name="python-3.11.1"
self_toolset_name="build-musl"
echo "::set-output name=tool_name::$tool_name"

release_version_dirpath="$dp0/release/$tool_name-$tool_version"
mkdir -p "$release_version_dirpath" && cd "$dp0/release"

echo "download python install script ..."
python_bin_download_url="https://github.com/hemnstill/StandaloneTools/releases/download/$self_name/$self_toolset_name.tar.gz"
python_download_zip="$dp0/release/$self_name.tar.gz"
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

#   File "/lib/python3.10/site-packages/dill/_dill.py", line 1854, in <module>
#     _PyCapsule_New = ctypes.pythonapi.PyCapsule_New
# AttributeError: 'NoneType' object has no attribute 'PyCapsule_New'
"$cpython_bin" -m pip install "https://github.com/uqfoundation/dill/releases/download/dill-0.3.6/dill-0.3.6-py3-none-any.whl"

"$cpython_bin" -m pip install "$tool_name==$tool_version"

cp -f "$dp0/release/pylint.sh" "$release_version_dirpath/"
cp -f "$dp0/release/__main__pylint.py" "$release_version_dirpath/"

echo "creating archive ..."

cd "$release_version_dirpath"
{ printf '### %s
%s
' "$self_toolset_name" "$(./"$tool_name.sh" --version)"
} > $self_toolset_name.md

cat $self_toolset_name.md

"$bsdtar" \
  --exclude="__pycache__" \
  --exclude="Scripts/Scripts" \
  --exclude="*.whl" \
  -czvf ../$self_toolset_name.tar.gz .
