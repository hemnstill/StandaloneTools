#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

is_windows_os=false && [[ $(uname) == Windows_NT* ]] && is_windows_os=true

tool_name="poetry.exe"
tool_version="1.2.1"
echo "::set-output name=tool_name::$tool_name"
echo "::set-output name=tool_version::$tool_version"

mkdir -p "$dp0/release/build" && cd "$dp0/release"

poetry_download_url="https://raw.githubusercontent.com/python-poetry/install.python-poetry.org/main/install-poetry.py"
poetry_install_script="install-poetry-$tool_version.py"
[[ ! -f "$poetry_install_script" ]] && wget "$poetry_download_url" -O "$poetry_install_script"

python_version=3.10.5
python_runtime_name="cpython-$python_version-linux-musl-noopt" && $is_windows_os && python_runtime_name="cpython-$python_version-windows-msvc"

linux_download_url="https://github.com/indygreg/python-build-standalone/releases/download/20220630/cpython-$python_version+20220630-x86_64-unknown-linux-musl-noopt-full.tar.zst"
windows_download_url="https://github.com/indygreg/python-build-standalone/releases/download/20220630/cpython-$python_version+20220630-x86_64-pc-windows-msvc-shared-pgo-full.tar.zst"
download_url="$linux_download_url" && $is_windows_os && download_url="$windows_download_url"
cpython_zip="raw_cpython-linux.tar.zst" && $is_windows_os && cpython_zip="raw_cpython-win.tar.zst"
[[ ! -f "$cpython_zip" ]] && wget "$download_url" -O "$cpython_zip"
