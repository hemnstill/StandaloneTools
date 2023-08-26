#!/bin/bash

is_alpine_os=false && [[ -f "/etc/alpine-release" ]] && is_alpine_os=true
is_ubuntu_os=false && [[ -f "/etc/lsb-release" ]] && is_ubuntu_os=true

../.tools/install_alpine_glibc.sh

if [[ "$is_alpine_os" == true ]]; then
  apk update
  apk add --no-cache libssl1.1 ncurses

  export LC_ALL=en_US.UTF-8
fi

if [[ "$is_ubuntu_os" == true ]]; then
  apt update
  apt install -y libssl
fi

testVersion() {
  ldd ../bin/mysql

  assertEquals "../bin/mysql  Ver 8.0.33 for Linux on x86_64 (Source distribution)" "$(../bin/mysql --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
