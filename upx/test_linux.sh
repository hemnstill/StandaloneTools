#!/bin/bash

is_fedora_os=false && [[ -f "/etc/fedora-release" ]] && is_fedora_os=true
is_rockylinux_os=false && [[ -f "/etc/rockylinux-release" ]] && is_rockylinux_os=true

if [[ "is_fedora_os" == true ]]; then
  yum -y install findutils
fi

if [[ "is_rockylinux_os" == true ]]; then
  yum -y install findutils
fi

testVersion() {
  assertEquals "upx 3.96" "$(../bin/upx --version | head -1)"
}

testPackedVersion() {
  assertEquals "upx 3.96" "$(../bin/upx_packed --version | head -1)"
}

testPackedBsdtarVersion() {
  assertEquals "bsdtar 3.6.2 - libarchive 3.6.2 zlib/1.2.12 liblzma/5.2.5 libzstd/1.5.2 " "$(../bin/bsdtar --version | head -1)"
}

testPackedBsdtarCreateArchive() {
  assertEquals "" "$(../bin/bsdtar -cvf bsdtar.tar.gz ../bin/bsdtar)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
