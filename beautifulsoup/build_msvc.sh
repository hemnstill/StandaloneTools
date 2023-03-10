#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

tool_name="beautifulsoup4"
tool_version="4.11.2"
self_name="python-3.11.1"
self_toolset_name="build-msvc"
echo "::set-output name=tool_name::$tool_name"

release_version_dirpath="$dp0/release/$tool_name-$tool_version"
mkdir -p "$release_version_dirpath" && cd "$dp0/release"

echo "download python install script ..."
python_bin_download_url="https://github.com/hemnstill/StandaloneTools/releases/download/$self_name/$self_toolset_name.tar.gz"
python_download_zip="$dp0/release/$self_name.tar.gz"
[[ ! -f "$python_download_zip" ]] && wget "$python_bin_download_url" -O "$python_download_zip"

echo "download bsdtar ..."
bsdtar_version=3.6.2
bsdtar_download_url="https://github.com/hemnstill/StandaloneTools/releases/download/bsdtar-$bsdtar_version/build-mingw.tar.gz"
bsdtar_tar_gz="bsdtar-$bsdtar_version-build-mingw.tar.gz"
[[ ! -f "$bsdtar_tar_gz" ]] && wget "$bsdtar_download_url" -O "$bsdtar_tar_gz"
tar -xf "$bsdtar_tar_gz"

bsdtar="$dp0/release/bsdtar.exe"

cpython_bin="$release_version_dirpath/Scripts/python.exe"
[[ ! -f "$cpython_bin" ]] && tar -xf "$python_download_zip" -C "$release_version_dirpath"

"$cpython_bin" -m pip install "lxml==4.9.2"
"$cpython_bin" -m pip install "html5lib==1.1"
"$cpython_bin" -m pip install "$tool_name==$tool_version"

echo "creating archive ..."

cd "$release_version_dirpath"
{ printf '### %s
bs4 %s
lxml %s
html5lib %s
' "$self_toolset_name.tar.gz" \
  "$("$cpython_bin" -c "import bs4; print(bs4.__version__)")" \
  "$("$cpython_bin" -c "import lxml; print(lxml.__version__)")" \
  "$("$cpython_bin" -c "import html5lib; print(html5lib.__version__)")"
} > $self_toolset_name.md

cat $self_toolset_name.md

"$bsdtar" \
  --exclude="__pycache__" \
  --exclude="Scripts/Scripts" \
  --exclude="*.whl" \
  -czvf ../$self_toolset_name.tar.gz .
