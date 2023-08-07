#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

tool_name="playwright"
tool_version="1.35.0"
self_name="python-3.10.5"
self_toolset_name="build-gnu"

apt update
apt install -y wget

release_version_dirpath="$dp0/release/$tool_name-$tool_version"
mkdir -p "$release_version_dirpath" && cd "$dp0/release"

echo "download python install script ..."
python_bin_download_url="https://github.com/hemnstill/StandaloneTools/releases/download/$self_name/build-gnu.tar.gz"
python_download_zip="$dp0/release/$self_name.tar.gz"
[[ ! -f "$python_download_zip" ]] && wget "$python_bin_download_url" -O "$python_download_zip"

"$dp0/../.tools/download_bsdtar.sh"
bsdtar="$dp0/release/bsdtar"

cpython_bin="$release_version_dirpath/Scripts/bin/python3"
[[ ! -f "$cpython_bin" ]] && tar -xf "$python_download_zip" -C "$release_version_dirpath"

"$cpython_bin" -m pip install "$tool_name==$tool_version"

cp -f "$dp0/release/playwright.sh" "$release_version_dirpath/"
cp -f "$dp0/release/__main__playwright.py" "$release_version_dirpath/"

export PLAYWRIGHT_BROWSERS_PATH="$release_version_dirpath/ms-playwright"
echo "download browsers to '$PLAYWRIGHT_BROWSERS_PATH' ..."
cd "$release_version_dirpath"
./"$tool_name.sh" install chromium

echo "creating archive ..."

{ printf '### %s.tar.gz
Playwright %s
Python %s

' "$self_toolset_name" "$(./"$tool_name.sh" --version)" "$("$cpython_bin" -c "import sys; print(sys.version)")"
} > "$self_toolset_name.md"

cat "$self_toolset_name.md"

"$bsdtar" \
  --exclude="__pycache__" \
  --exclude="Scripts/Scripts" \
  --exclude="*.whl" \
  -czvf "../$self_toolset_name.tar.gz" .
