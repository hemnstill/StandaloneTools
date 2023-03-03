#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

apk update
apk add --no-cache alpine-sdk python3-dev gcompat

{ printf '%s' "-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApZ2u1KJKUu/fW4A25y9m
y70AGEa/J3Wi5ibNVGNn1gT1r0VfgeWd0pUybS4UmcHdiNzxJPgoWQhV2SSW1JYu
tOqKZF5QSN6X937PTUpNBjUvLtTQ1ve1fp39uf/lEXPpFpOPL88LKnDBgbh7wkCp
m2KzLVGChf83MS0ShL6G9EQIAUxLm99VpgRjwqTQ/KfzGtpke1wqws4au0Ab4qPY
KXvMLSPLUp7cfulWvhmZSegr5AdhNw5KNizPqCJT8ZrGvgHypXyiFvvAH5YRtSsc
Zvo9GI2e2MaZyo9/lvb+LbLEJZKEQckqRj4P26gmASrZEPStwc+yqy1ShHLA0j6m
1QIDAQAB
-----END PUBLIC KEY-----"
} > "/etc/apk/keys/sgerrand.rsa.pub"

wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r0/glibc-2.35-r0.apk
wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r0/glibc-bin-2.35-r0.apk
wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r0/glibc-i18n-2.35-r0.apk
apk add --force-overwrite glibc-2.35-r0.apk glibc-bin-2.35-r0.apk glibc-i18n-2.35-r0.apk
/usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8
export LC_ALL=en_US.UTF-8

tool_name="ansible"
tool_version="7.1.0"
tool_core_version="2.14.1"
tool_lint_version="6.13.1"
python_self_name="python-3.11.1"
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

"$cpython_bin" -m pip install "ansible-core==$tool_core_version"
"$cpython_bin" -m pip install "$tool_name==$tool_version"
"$cpython_bin" -m pip install "ansible-lint==$tool_lint_version"

echo "prepare build artifacts ..."

cp -f "$dp0/release/ansible.sh" "$release_version_dirpath/"
cp -f "$dp0/release/__main__ansible.py" "$release_version_dirpath/"
cp -f "$dp0/release/_ansible" "$release_version_dirpath/Scripts/bin/ansible"

cp -f "$dp0/release/ansible-config.sh" "$release_version_dirpath/"
cp -f "$dp0/release/__main__ansible-config.py" "$release_version_dirpath/"
cp -f "$dp0/release/_ansible-config" "$release_version_dirpath/Scripts/bin/ansible-config"

cp -f "$dp0/release/ansible-playbook.sh" "$release_version_dirpath/"
cp -f "$dp0/release/__main__ansible-playbook.py" "$release_version_dirpath/"
cp -f "$dp0/release/_ansible-playbook" "$release_version_dirpath/Scripts/bin/ansible-playbook"

cp -f "$dp0/release/ansible-lint.sh" "$release_version_dirpath/"
cp -f "$dp0/release/__main__ansible-lint.py" "$release_version_dirpath/"

echo "creating archive ..."

cd "$release_version_dirpath"

./"$tool_name.sh" --version

{ printf '### build-gnu.tar.gz
%s

%s

%s

%s

' "$(./"$tool_name.sh" --version)" \
  "$(./"ansible-config.sh" --version | head -1)" \
  "$(./"ansible-playbook.sh" --version | head -1)" \
  "$(./"ansible-lint.sh" --version)"
} > build-gnu.md

cat build-gnu.md

"$bsdtar" \
  --exclude="__pycache__" \
  --exclude="Scripts/Scripts" \
  --exclude="*.whl" \
  -czvf ../build-gnu.tar.gz .
