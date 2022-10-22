#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

tool_name="pylint"
tool_version="2.15.3"
poetry_name_version="poetry-1.2.2"
echo "::set-output name=tool_name::$tool_name"

mkdir -p "$dp0/release/$tool_name-$tool_version" && cd "$dp0/release"

echo "download poetry install script ..."
poetry_bin_download_url="https://github.com/hemnstill/StandaloneTools/releases/download/$poetry_name_version/build-msvc.tar.gz"
poetry_download_zip="$dp0/release/$poetry_name_version.tar.gz"
[[ ! -f "$poetry_download_zip" ]] && wget "$poetry_bin_download_url" -O "$poetry_download_zip"

poetry_bin="$dp0/release/poetry.bat"
[[ ! -f "$poetry_bin" ]] && tar -xf "$poetry_download_zip"

"$poetry_bin" install
