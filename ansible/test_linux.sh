#!/bin/bash

is_alpine_os=false && [[ -f "/etc/alpine-release" ]] && is_alpine_os=true
is_ubuntu_os=false && [[ -f "/etc/lsb-release" ]] && is_ubuntu_os=true

if [[ "$is_alpine_os" == true ]]; then
  apk update
  apk add --no-cache gcompat git

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
fi

if [[ "$is_ubuntu_os" == true ]]; then
  apt update
  apt install -y git
fi

test_version() {
  assertEquals "ansible [core 2.14.5]
  config file = None
  configured module search path = ['/github/home/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /__w/StandaloneTools/StandaloneTools/bin/Scripts/lib/python3.11/site-packages/ansible
  ansible collection location = /github/home/.ansible/collections:/usr/share/ansible/collections
  executable location = /__w/StandaloneTools/StandaloneTools/bin/__main__ansible.py
  python version = 3.11.1 (main, Jan 16 2023, 22:40:32) [Clang 15.0.7 ] (/__w/StandaloneTools/StandaloneTools/bin/Scripts/bin/python3)
  jinja version = 3.1.2
  libyaml = True" "$(../bin/ansible.sh --version)"
}

test_bin_version() {
  assertEquals "ansible [core 2.14.5]" "$(../bin/Scripts/bin/ansible --version | head -1)"
}

test_ansible_config_version() {
  assertEquals "ansible-config [core 2.14.5]" "$(../bin/Scripts/bin/ansible-config --version | head -1)"
}

test_ansible_playbook_version() {
  assertEquals "ansible-playbook [core 2.14.5]" "$(../bin/Scripts/bin/ansible-playbook --version | head -1)"
}

test_ansible_galaxy_version() {
  assertEquals "ansible-galaxy [core 2.14.5]" "$(../bin/ansible-galaxy.sh --version | head -1)"
}

test_ansible_lint_version() {
  assertEquals "ansible-lint 6.16.0 using ansible 2.14.5" "$(../bin/ansible-lint.sh --version | head -1)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
