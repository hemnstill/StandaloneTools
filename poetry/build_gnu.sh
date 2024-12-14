#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

apt update
apt install -y wget binutils curl clang pkg-config

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

tool_name="poetry"
tool_version="1.8.5"
python_self_name="python-3.13.1"
self_name="$tool_name-$tool_version"
self_toolset_name="build-gnu"
release_version_dirpath="$dp0/release/$self_name"

mkdir -p "$release_version_dirpath" && cd "$dp0/release"

echo "download python install script ..."
python_bin_download_url="https://github.com/hemnstill/StandaloneTools/releases/download/$python_self_name/$self_toolset_name.tar.gz"

echo "::group::prepare sources $python_bin_download_url"

python_download_zip="$dp0/release/$python_self_name.tar.gz"
[[ ! -f "$python_download_zip" ]] && wget "$python_bin_download_url" -O "$python_download_zip"

"$dp0/../.tools/download_bsdtar.sh"
bsdtar="$dp0/release/bsdtar"

cpython_bin="$release_version_dirpath/Scripts/bin/python3"
[[ ! -f "$cpython_bin" ]] && tar -xf "$python_download_zip" -C "$release_version_dirpath"

echo "::endgroup::"

echo "::group::build"

echo "install poetry ..."
"$cpython_bin" -m pip install "poetry==$tool_version"
"$cpython_bin" -m poetry self add poetry-plugin-sort
"$cpython_bin" -m poetry self lock

echo "::endgroup::"

echo "prepare build artifacts ..."

cp -f "$dp0/release/poetry.sh" "$release_version_dirpath/"
cp -f "$dp0/release/__main__poetry.py" "$release_version_dirpath/"

echo "creating archive ..."

cd "$release_version_dirpath"
{ printf '### %s
%s
Python %s

<details>
  <summary>poetry self show</summary>

```
%s
```
</details>

<details>
  <summary>poetry self show plugins</summary>

```
%s
```
</details>

' "$self_toolset_name.tar.gz" \
  "$(./"$tool_name.sh" about)" \
  "$("$cpython_bin" -c "import sys; print(sys.version)")" \
  "$(./"$tool_name.sh" self show)" \
  "$(./"$tool_name.sh" self show plugins)"
} > $self_toolset_name.md

cat $self_toolset_name.md

"$bsdtar" \
  --exclude="__pycache__" \
  --exclude="Scripts/Scripts" \
  -czvf ../$self_toolset_name.tar.gz .
