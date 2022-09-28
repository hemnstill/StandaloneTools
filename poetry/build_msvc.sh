#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

tool_name="poetry.exe"
tool_version="1.2.1"
echo "::set-output name=tool_name::$tool_name"
echo "::set-output name=tool_version::$tool_version"

# Скачать python portable

# Установить poetry через https://install.python-poetry.org/

poetry_download_url="https://raw.githubusercontent.com/python-poetry/install.python-poetry.org/main/install-poetry.py"

wget "$poetry_download_url" -O "install-poetry-$tool_version.py"
