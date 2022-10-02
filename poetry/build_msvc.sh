#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

is_windows_os=false && [[ $(uname) == Windows_NT* ]] && is_windows_os=true

tool_name="poetry.exe"
tool_version="1.2.1"
echo "::set-output name=tool_name::$tool_name"
echo "::set-output name=tool_version::$tool_version"

mkdir -p "$dp0/release/build" && cd "$dp0/release"

echo "download poetry install script ..."
poetry_download_url="https://raw.githubusercontent.com/python-poetry/install.python-poetry.org/main/install-poetry.py"
poetry_install_script="install-poetry-$tool_version.py"
[[ ! -f "$poetry_install_script" ]] && wget "$poetry_download_url" -O "$poetry_install_script"

echo "download python ..."
python_version=3.10.5
python_runtime_name="cpython-$python_version-linux-musl-noopt" && $is_windows_os && python_runtime_name="cpython-$python_version-windows-msvc"

linux_download_url="https://github.com/indygreg/python-build-standalone/releases/download/20220630/cpython-$python_version+20220630-x86_64-unknown-linux-musl-noopt-full.tar.zst"
windows_download_url="https://github.com/indygreg/python-build-standalone/releases/download/20220630/cpython-$python_version+20220630-x86_64-pc-windows-msvc-shared-pgo-full.tar.zst"
download_url="$linux_download_url" && $is_windows_os && download_url="$windows_download_url"
cpython_zip="$dp0/release/raw_cpython-linux.tar.zst" && $is_windows_os && cpython_zip="$dp0/release/raw_cpython-win.tar.zst"
[[ ! -f "$cpython_zip" ]] && wget "$download_url" -O "$cpython_zip"

echo "download bsdtar ..."
bsdtar_download_url="https://github.com/hemnstill/StandaloneTools/releases/download/bsdtar-3.6.1/build-mingw.tar.gz"
bsdtar_tar_gz="bsdtar-3.6.1_build-mingw.tar.gz"
[[ ! -f "$bsdtar_tar_gz" ]] && wget "$bsdtar_download_url" -O "$bsdtar_tar_gz"
tar -xf "$bsdtar_tar_gz"

bsdtar="$dp0/release/bsdtar.exe"
cpython_bin="$dp0/.tmp/python/install/python.exe"
if [[ ! -f "$cpython_bin" ]]; then
  echo extract "$cpython_zip" to "$cpython_bin" ...
  rm -rf "$dp0/.tmp/"* && mkdir -p "$dp0/.tmp" && cd "$dp0/.tmp" || exit 1

  "$bsdtar" \
  --exclude="__pycache__" \
  --exclude="test" \
  --exclude="tests" \
  --exclude="idle_test" \
  --exclude="site-packages" \
  --exclude="venv" \
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


echo "install poetry ..."
export POETRY_HOME="$dp0/.tmp/poetry"
"$cpython_bin" "$dp0/release/$poetry_install_script" --version "$tool_version"

echo "prepare build artifacts ..."
rm -rf "$dp0/release/build" && mkdir -p "$dp0/release/build"
cp -rf "$dp0/.tmp/poetry/venv/Lib" "$dp0/release/build/"
cp -rf "$dp0/.tmp/python/install" "$dp0/release/build/Python/"
cp -f "$dp0/release/poetry.bat" "$dp0/release/build/"
cp -f "$dp0/release/__main__.py" "$dp0/release/build/"

makeself_tool_version=release-2.4.5-cmd
makeself_download_url="https://github.com/hemnstill/makeself/archive/refs/tags/$makeself_tool_version.tar.gz"

makeself_version_path="$dp0/tool-$makeself_tool_version.tar.gz"
makeself_target_path="$dp0/makeself-$makeself_tool_version"
makeself_sh_path="$makeself_target_path/makeself.sh"

[[ ! -f "$makeself_version_path" ]] && {
  echo "::group::prepare sources $makeself_download_url"
  wget "$makeself_download_url" -O "$makeself_version_path"
  tar -xf "$makeself_version_path"
}
