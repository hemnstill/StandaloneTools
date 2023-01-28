#!/bin/bash

is_fedora_os=false && [[ -f "/etc/fedora-release" ]] && is_fedora_os=true
is_rockylinux_os=false && [[ -f "/etc/rocky-release" ]] && is_rockylinux_os=true

if [[ "$is_fedora_os" == true ]]; then
  cat "/etc/fedora-release"
  yum -y install findutils
fi

if [[ "$is_rockylinux_os" == true ]]; then
  cat "/etc/rocky-release"
  yum -y install findutils
fi

testVersion() {
  assertEquals "upx 3.96" "$(../bin/upx --version | head -1)"
}

testPackedVersion() {
  assertEquals "upx 3.96" "$(../bin/upx_packed --version | head -1)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
