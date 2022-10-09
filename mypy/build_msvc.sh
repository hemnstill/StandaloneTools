#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

is_windows_os=false && [[ $(uname) == Windows_NT* ]] && is_windows_os=true

tool_name="pylint"
tool_version="0.982"
poetry_name_version="poetry-1.2.1"
echo "::set-output name=tool_name::$tool_name"

mkdir -p "$dp0/release/$tool_name-$tool_version" && cd "$dp0/release"

echo "download poetry install script ..."
poetry_bin_download_url="https://github.com/hemnstill/StandaloneTools/releases/download/poetry-1.2.1-beta/$poetry_name_version.sh.bat"
poetry_download_bin="$dp0/release/$poetry_name_version.sh.bat"
[[ ! -f "$poetry_download_bin" ]] && wget "$poetry_bin_download_url" -O "$poetry_download_bin"

poetry_bin="$dp0/release/$poetry_name_version/poetry.bat"
[[ ! -f "$poetry_bin" ]] && "$poetry_download_bin"

$poetry_bin install
