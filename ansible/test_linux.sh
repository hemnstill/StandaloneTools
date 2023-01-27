#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"

test_version() {
  assertEquals "ansible [core 2.14.1]
  config file = None
  configured module search path = ['/github/home/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /__w/StandaloneTools/StandaloneTools/bin/python/install/lib/python3.10/site-packages/ansible
  ansible collection location = /github/home/.ansible/collections:/usr/share/ansible/collections
  executable location = /__w/StandaloneTools/StandaloneTools/bin/__main__ansible.py
  python version = 3.10.9 (main, Dec 21 2022, 04:02:04) [Clang 14.0.3 ] (/__w/StandaloneTools/StandaloneTools/bin/python/install/bin/python3)
  jinja version = 3.1.2
  libyaml = True" "$(../bin/ansible.sh --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
