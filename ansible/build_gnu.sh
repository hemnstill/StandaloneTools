#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

apk update
apk add --no-cache alpine-sdk python3-dev bash

"$dp0/../.tools/install_alpine_glibc.sh"

export LC_ALL=en_US.UTF-8

tool_name="ansible"
tool_version="7.6.0"
tool_lint_version="6.16.2"
python_self_name="python-3.11.3"
self_name="$tool_name-$tool_version"
release_version_dirpath="$dp0/release/$self_name"
echo "::set-output name=tool_name::$tool_name"
echo "::set-output name=tool_version::$tool_version"

mkdir -p "$release_version_dirpath/Scripts/bin" && cd "$dp0/release"

echo "download python install script ..."
python_bin_download_url="https://github.com/hemnstill/StandaloneTools/releases/download/$python_self_name/build-gnu.tar.gz"
python_download_zip="$dp0/release/$python_self_name.tar.gz"
[[ ! -f "$python_download_zip" ]] && wget "$python_bin_download_url" -O "$python_download_zip"

echo "download bsdtar ..."
bsdtar_version=3.6.2
bsdtar_download_url="https://github.com/hemnstill/StandaloneTools/releases/download/bsdtar-$bsdtar_version/build-musl.tar.gz"
bsdtar_tar_gz="bsdtar-$bsdtar_version-build-musl.tar.gz"
[[ ! -f "$bsdtar_tar_gz" ]] && wget "$bsdtar_download_url" -O "$bsdtar_tar_gz"
tar -xf "$bsdtar_tar_gz"

bsdtar="$dp0/release/bsdtar"
cpython_bin="$release_version_dirpath/Scripts/bin/python3"
cpython_lib_path="$release_version_dirpath/Scripts/lib/python3.10/site-packages"
[[ ! -f "$cpython_bin" ]] && "$bsdtar" -xf "$python_download_zip" -C "$release_version_dirpath"

echo "install ansbile ..."

"python3" -m ensurepip
"python3" -m pip install --target="$cpython_lib_path" cffi

"$cpython_bin" -m pip install "$tool_name==$tool_version"
"$cpython_bin" -m pip install "ansible-lint==$tool_lint_version"

echo "prepare build artifacts ..."

cp -f "$dp0/release/__main__ansible.py" "$release_version_dirpath/"
cp -f "$dp0/release/_ansible" "$release_version_dirpath/Scripts/bin/ansible"

cp -f "$dp0/release/__main__ansible-config.py" "$release_version_dirpath/"
cp -f "$dp0/release/ansible-config" "$release_version_dirpath/Scripts/bin/"

cp -f "$dp0/release/__main__ansible-playbook.py" "$release_version_dirpath/"
cp -f "$dp0/release/ansible-playbook" "$release_version_dirpath/Scripts/bin/"

cp -f "$dp0/release/__main__ansible-galaxy.py" "$release_version_dirpath/"
cp -f "$dp0/release/ansible-galaxy" "$release_version_dirpath/Scripts/bin/"

cp -f "$dp0/release/__main__ansible-lint.py" "$release_version_dirpath/"
cp -f "$dp0/release/ansible-lint" "$release_version_dirpath/Scripts/bin/"

cp -f "$dp0/release/__main__ansible-test.py" "$release_version_dirpath/"
cp -f "$dp0/release/ansible-test" "$release_version_dirpath/Scripts/bin/"

echo "creating archive ..."

cd "$release_version_dirpath"

"./Scripts/bin/$tool_name" --version

{ printf '### build-gnu.tar.gz
%s

%s

%s

%s

%s

%s

' "$("./Scripts/bin/$tool_name" --version)" \
  "$("./Scripts/bin/ansible-config" --version | head -1)" \
  "$("./Scripts/bin/ansible-playbook" --version | head -1)" \
  "$("./Scripts/bin/ansible-galaxy" --version | head -1)" \
  "$("./Scripts/bin/ansible-lint" --version | head -1)" \
  "$("./Scripts/bin/ansible-test" --version | head -1)"
} > build-gnu.md

cat build-gnu.md

"$bsdtar" \
  --exclude="__pycache__" \
  --exclude="Scripts/Scripts" \
  --exclude="Scripts/lib/python3.10" \
  --exclude="*.whl" \
  -czvf ../build-gnu.tar.gz .
