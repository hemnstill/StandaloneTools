#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

tool_name="python"
tool_version="3.10.5"
release_date="20220630"
self_name="$tool_name-$tool_version"
release_version_dirpath="$dp0/release/$self_name"

mkdir -p "$release_version_dirpath" && cd "$dp0/release"
download_url="https://github.com/indygreg/python-build-standalone/releases/download/$release_date/cpython-$tool_version+$release_date-x86_64-pc-windows-msvc-shared-pgo-full.tar.zst"
cpython_zip="$dp0/release/raw_cpython-win.tar.zst"
echo "download python from $download_url ..."
[[ ! -f "$cpython_zip" ]] && wget "$download_url" -O "$cpython_zip"

"$dp0/../.tools/download_bsdtar.sh"
bsdtar="$dp0/release/bsdtar"

cpython_bin="$dp0/.tmp/python/install/python.exe"
if [[ ! -f "$cpython_bin" ]]; then
  echo extract "$cpython_zip" to "$cpython_bin" ...
  rm -rf "$dp0/.tmp/"* && mkdir -p "$dp0/.tmp" && cd "$dp0/.tmp" || exit 1

  "$bsdtar" \
  --exclude="__pycache__" \
  --exclude="test" \
  --exclude="tests" \
  --exclude="idle_test" \
  --exclude="Scripts" \
  --exclude="*.pdb" \
  --exclude="*.whl" \
  --exclude="*.a" \
  --exclude="*.lib" \
  --exclude="*.pickle" \
  --exclude="python/install/include" \
  --exclude="tcl*.dll" \
  --exclude="lib/tcl*" \
  --exclude="tk*.dll" \
  --exclude="lib/tk*" \
  --exclude="python/install/tcl" \
  --exclude="python/install/share" \
  -xf "$cpython_zip" python/install
fi;

echo "prepare build artifacts ..."
rm -rf "$dp0/release/$self_name" && mkdir -p "$dp0/release/$self_name"
python_scripts_path="$dp0/release/$self_name/Scripts"
cp -rf "$dp0/.tmp/python/install" "$python_scripts_path/"

echo "creating archive ..."
cd "$release_version_dirpath"
{ printf '### build-msvc.tar.gz
Python %s
%s
%s
' "$("$cpython_bin" -c "import sys; print(sys.version)")" "$("$cpython_bin" -m pip --version)" "$download_url"
} > build-msvc.md

cat build-msvc.md

"$bsdtar" \
  --exclude="__pycache__" \
  --exclude="Scripts/Scripts" \
  --exclude="*.whl" \
  -czvf ../build-msvc.tar.gz .
