#!/bin/bash

is_alpine_os=false && [[ -f "/etc/alpine-release" ]] && is_alpine_os=true
is_ubuntu_os=false && [[ -f "/etc/lsb-release" ]] && is_ubuntu_os=true

../.tools/install_alpine_glibc.sh

if [[ "$is_alpine_os" == true ]]; then
  apk update
  apk add --no-cache git

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
  python version = 3.11.3 (main, May  7 2023, 19:33:53) [Clang 16.0.3 ] (/__w/StandaloneTools/StandaloneTools/bin/Scripts/bin/python3)
  jinja version = 3.1.2
  libyaml = True" "$(../bin/Scripts/bin/ansible --version)"
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
  assertEquals "ansible-galaxy [core 2.14.5]" "$(../bin/Scripts/bin/ansible-galaxy --version | head -1)"
}

test_ansible_lint_version() {
  assertEquals "ansible-lint 6.16.2 using ansible-core:2.14.5 ruamel-yaml:0.17.26 ruamel-yaml-clib:0.2.7" "$(../bin/Scripts/bin/ansible-lint --version | head -1)"
}

test_ansible_test_version() {
  assertEquals "ansible-test version 2.14.5" "$(../bin/Scripts/bin/ansible-test --version | head -1)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
