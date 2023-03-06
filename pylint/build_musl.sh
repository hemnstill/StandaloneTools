#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

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

tool_name="pylint"
tool_version="2.16.4"
self_name="python-3.11.1"
self_toolset_name="build-musl"
echo "::set-output name=tool_name::$tool_name"

release_version_dirpath="$dp0/release/$tool_name-$tool_version"
mkdir -p "$release_version_dirpath" && cd "$dp0/release"

echo "download python install script ..."
python_bin_download_url="https://github.com/hemnstill/StandaloneTools/releases/download/$self_name/build-gnu.tar.gz"
python_download_zip="$dp0/release/$self_name.tar.gz"
[[ ! -f "$python_download_zip" ]] && wget "$python_bin_download_url" -O "$python_download_zip"

echo "download bsdtar ..."
bsdtar_version=3.6.2
bsdtar_download_url="https://github.com/hemnstill/StandaloneTools/releases/download/bsdtar-$bsdtar_version/build-musl.tar.gz"
bsdtar_tar_gz="bsdtar-$bsdtar_version-build-musl.tar.gz"
[[ ! -f "$bsdtar_tar_gz" ]] && wget "$bsdtar_download_url" -O "$bsdtar_tar_gz"
tar -xf "$bsdtar_tar_gz"

bsdtar="$dp0/release/bsdtar"

cpython_bin="$release_version_dirpath/Scripts/bin/python3"
[[ ! -f "$cpython_bin" ]] && tar -xf "$python_download_zip" -C "$release_version_dirpath"

#   File "/lib/python3.10/site-packages/dill/_dill.py", line 1854, in <module>
#     _PyCapsule_New = ctypes.pythonapi.PyCapsule_New
# AttributeError: 'NoneType' object has no attribute 'PyCapsule_New'
# "$cpython_bin" -m pip install "https://github.com/uqfoundation/dill/releases/download/dill-0.3.6/dill-0.3.6-py3-none-any.whl"

"$cpython_bin" -m pip install "$tool_name==$tool_version"

cp -f "$dp0/release/pylint.sh" "$release_version_dirpath/"
cp -f "$dp0/release/__main__pylint.py" "$release_version_dirpath/"

echo "creating archive ..."

cd "$release_version_dirpath"
{ printf '### %s
%s
' "$self_toolset_name" "$(./"$tool_name.sh" --version)"
} > $self_toolset_name.md

cat $self_toolset_name.md

"$bsdtar" \
  --exclude="__pycache__" \
  --exclude="Scripts/Scripts" \
  --exclude="*.whl" \
  -czvf ../$self_toolset_name.tar.gz .
