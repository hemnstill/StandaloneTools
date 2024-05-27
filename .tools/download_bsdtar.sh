#!/bin/bash

is_windows_os=false && [[ $(uname) == Windows_NT* || $(uname) == MINGW64_NT* ]] && is_windows_os=true

echo "download bsdtar ..."
bsdtar_version=3.7.4
bsdtar_toolset_name="build-musl" && [[ "$is_windows_os" == true ]] && bsdtar_toolset_name="build-mingw"

bsdtar_download_url="https://github.com/hemnstill/StandaloneTools/releases/download/bsdtar-$bsdtar_version/$bsdtar_toolset_name.tar.gz"
bsdtar_tar_gz="bsdtar-$bsdtar_version-$bsdtar_toolset_name.tar.gz"
[[ ! -f "$bsdtar_tar_gz" ]] && wget "$bsdtar_download_url" -O "$bsdtar_tar_gz"
tar -xf "$bsdtar_tar_gz"
